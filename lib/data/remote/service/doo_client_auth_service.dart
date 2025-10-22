import 'dart:convert';
import 'package:doo_cx_flutter_sdk/data/local/entity/doo_contact.dart';
import 'package:doo_cx_flutter_sdk/data/local/entity/doo_conversation.dart';
import 'package:doo_cx_flutter_sdk/data/local/entity/doo_user.dart';
import 'package:doo_cx_flutter_sdk/data/remote/doo_client_exception.dart';
import 'package:dio/dio.dart';

abstract class DOOClientAuthService {
  final Dio dio;
  DOOClientAuthService(this.dio);

  Future<DOOContact> createNewContact(String inboxIdentifier, DOOUser? user);
  Future<DOOConversation> createNewConversation(
      String inboxIdentifier, String contactIdentifier);
}

class DOOClientAuthServiceImpl extends DOOClientAuthService {
  DOOClientAuthServiceImpl({required Dio dio}) : super(dio) {
    // Install verbose wire logging for debugging
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (obj) {
        // Optional: redact Authorization tokens if you use them
        final line = obj.toString().replaceAll(
              RegExp(r'Authorization:\s*Bearer\s+[A-Za-z0-9\-\._~\+\/]+=*'),
              'Authorization: Bearer <REDACTED>',
            );
        // ignore: avoid_print
        print(line);
      },
    ));
  }

  @override
  Future<DOOContact> createNewContact(
      String inboxIdentifier, DOOUser? user) async {
    try {
      final res = await dio.post(
        "/public/api/v1/inboxes/$inboxIdentifier/contacts",
        data: user?.toJson(),
      );
      if ((res.statusCode ?? 0).isBetween(199, 300)) {
        return DOOContact.fromJson(res.data);
      }
      throw DOOClientException(
        res.statusMessage ?? "unknown error",
        DOOClientExceptionType.CREATE_CONTACT_FAILED,
      );
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final body = e.response?.data;
      final url = e.requestOptions.uri.toString();
      throw DOOClientException(
        "createNewContact failed: status=$code url=$url body=${_pretty(body)}",
        DOOClientExceptionType.CREATE_CONTACT_FAILED,
      );
    }
  }

  @override
  Future<DOOConversation> createNewConversation(
      String inboxIdentifier, String contactIdentifier) async {
    try {
      final res = await dio.post(
        "/public/api/v1/inboxes/$inboxIdentifier/contacts/$contactIdentifier/conversations",
      );
      if ((res.statusCode ?? 0).isBetween(199, 300)) {
        return DOOConversation.fromJson(res.data);
      }
      throw DOOClientException(
        res.statusMessage ?? "unknown error",
        DOOClientExceptionType.CREATE_CONVERSATION_FAILED,
      );
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final body = e.response?.data;
      final url = e.requestOptions.uri.toString();
      throw DOOClientException(
        "createNewConversation failed: status=$code url=$url body=${_pretty(body)}",
        DOOClientExceptionType.CREATE_CONVERSATION_FAILED,
      );
    }
  }
}

extension on num {
  bool isBetween(num from, num to) => from < this && this < to;
}

String _pretty(dynamic data) {
  if (data == null) return 'null';
  if (data is String) return data;
  try {
    return const JsonEncoder.withIndent('  ').convert(data);
  } catch (_) {
    return data.toString();
  }
}
