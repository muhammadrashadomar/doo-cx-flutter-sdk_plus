import 'dart:convert';
import 'package:doo_cx_flutter_sdk/data/local/entity/doo_contact.dart';
import 'package:doo_cx_flutter_sdk/data/local/entity/doo_conversation.dart';
import 'package:doo_cx_flutter_sdk/data/local/local_storage.dart';
import 'package:doo_cx_flutter_sdk/data/remote/doo_client_exception.dart';
import 'package:doo_cx_flutter_sdk/data/remote/service/doo_client_auth_service.dart';
import 'package:dio/dio.dart';
import 'package:synchronized/synchronized.dart' as synchronized;

/// Intercepts network requests and attaches inbox identifier, contact identifiers, conversation identifiers
class DOOClientApiInterceptor extends Interceptor {
  static const INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER = "{INBOX_IDENTIFIER}";
  static const INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER =
      "{CONTACT_IDENTIFIER}";
  static const INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER =
      "{CONVERSATION_IDENTIFIER}";

  final String _inboxIdentifier;
  final LocalStorage _localStorage;
  final DOOClientAuthService _authService;
  final requestLock = synchronized.Lock();
  final responseLock = synchronized.Lock();

  DOOClientApiInterceptor(
      this._inboxIdentifier, this._localStorage, this._authService);

  /// Ensure we have a contact + conversation before the request goes out.
  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    await requestLock.synchronized(() async {
      RequestOptions newOptions = options;

      DOOContact? contact = _localStorage.contactDao.getContact();
      DOOConversation? conversation =
          _localStorage.conversationDao.getConversation();

      try {
        if (contact == null) {
          // Bootstrap: create contact then conversation
          print(
              '[DOO SDK] No contact found. Creating new contact for inbox=$_inboxIdentifier ...');
          contact = await _authService.createNewContact(
            _inboxIdentifier,
            _localStorage.userDao.getUser(),
          );
          print('[DOO SDK] Contact created: ${contact.contactIdentifier}');

          conversation = await _authService.createNewConversation(
            _inboxIdentifier,
            contact.contactIdentifier!,
          );
          print('[DOO SDK] Conversation created: ${conversation.id}');

          await _localStorage.contactDao.saveContact(contact);
          await _localStorage.conversationDao.saveConversation(conversation);
        }

        if (conversation == null) {
          print(
              '[DOO SDK] No conversation found. Creating new conversation for contact=${contact.contactIdentifier} ...');
          conversation = await _authService.createNewConversation(
            _inboxIdentifier,
            contact!.contactIdentifier!,
          );
          await _localStorage.conversationDao.saveConversation(conversation);
          print('[DOO SDK] Conversation created: ${conversation.id}');
        }
      } on DioException catch (e) {
        final code = e.response?.statusCode;
        final body = e.response?.data;
        final url = e.requestOptions.uri.toString();
        final path = e.requestOptions.path;
        final exType = path.contains('/conversations')
            ? DOOClientExceptionType.CREATE_CONVERSATION_FAILED
            : DOOClientExceptionType.CREATE_CONTACT_FAILED;
        print(
            '[DOO SDK] Bootstrap (contact/conversation) failed. status=$code url=$url body=${_pretty(body)}');
        // Re-throw as your domain exception to keep behavior but with context
        throw DOOClientException(
          'Bootstrap failed: status=$code url=$url body=${_pretty(body)}',
          exType,
          data: {
            'status': code,
            'url': url,
            'body': body,
          },
        );
      } catch (e) {
        print('[DOO SDK] Bootstrap unexpected error: $e');
        rethrow;
      }

      // Replace placeholders AFTER we know we have ids
      newOptions.path = newOptions.path
          .replaceAll(
              INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER, _inboxIdentifier)
          .replaceAll(INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER,
              contact!.contactIdentifier!)
          .replaceAll(INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER,
              '${conversation!.id}');

      handler.next(newOptions);
    });
  }

  /// Handle 401/403/404 by clearing cached ids and fully re-creating contact + conversation,
  /// then retrying the original request with placeholders replaced.
  /// Handle 429 with bounded retry.
  @override
  Future<void> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    await responseLock.synchronized(() async {
      // 429 — Retry once after delay (respect Retry-After if present)
      if (response.statusCode == 429) {
        final retryAfter = response.headers['retry-after']?.first;
        int delaySeconds = int.tryParse(retryAfter ?? '') ?? 5;
        if (delaySeconds > 60) delaySeconds = 60;

        print('[DOO SDK] 429 Rate limited. Retrying after $delaySeconds s ...');
        await Future.delayed(Duration(seconds: delaySeconds));

        try {
          final retryResponse =
              await _authService.dio.fetch(response.requestOptions);
          handler.next(retryResponse);
          return;
        } catch (e) {
          print('[DOO SDK] 429 retry failed: $e');
          handler.next(response); // Fall back to original response
          return;
        }
      }

      // 401/403/404 — re-bootstrap
      if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404) {
        print(
            '[DOO SDK] ${response.statusCode} received. Clearing local DOO state and re-creating contact + conversation ...');

        // Keep user but clear DOO contact/conversation
        await _localStorage.clear(clearDOOUserStorage: false);

        DOOContact? contact;
        DOOConversation? conversation;

        try {
          contact = await _authService.createNewContact(
            _inboxIdentifier,
            _localStorage.userDao.getUser(),
          );
          print('[DOO SDK] Re-created contact: ${contact.contactIdentifier}');

          conversation = await _authService.createNewConversation(
            _inboxIdentifier,
            contact.contactIdentifier!,
          );
          print('[DOO SDK] Re-created conversation: ${conversation.id}');

          await _localStorage.contactDao.saveContact(contact);
          await _localStorage.conversationDao.saveConversation(conversation);
        } on DioException catch (e) {
          final code = e.response?.statusCode;
          final body = e.response?.data;
          print(
              '[DOO SDK] Re-bootstrap failed. status=$code body=${_pretty(body)}');
          // Stop here—propagate the original response since retry won't succeed
          handler.next(response);
          return;
        } catch (e) {
          print('[DOO SDK] Re-bootstrap unexpected error: $e');
          handler.next(response);
          return;
        }

        // Prepare a fresh RequestOptions with replaced placeholders
        final retryOptions = response.requestOptions;
        retryOptions.path = retryOptions.path
            .replaceAll(
                INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER, _inboxIdentifier)
            .replaceAll(INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER,
                contact!.contactIdentifier!)
            .replaceAll(INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER,
                '${conversation!.id}');

        try {
          final retried = await _authService.dio.fetch(retryOptions);
          handler.next(retried);
          return;
        } catch (e) {
          print('[DOO SDK] Retry after re-bootstrap failed: $e');
          handler.next(response);
          return;
        }
      }

      // Forward all other responses
      handler.next(response);
    });
  }

  static String _pretty(dynamic data) {
    if (data == null) return 'null';
    if (data is String) return data;
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }
}

extension Range on num {
  bool isBetween(num from, num to) => from < this && this < to;
}
