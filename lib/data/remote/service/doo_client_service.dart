import 'dart:async';
import 'dart:convert';

import 'package:doo_cx_flutter_sdk_plus/data/local/entity/doo_contact.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/entity/doo_conversation.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/entity/doo_message.dart';
import 'package:doo_cx_flutter_sdk_plus/data/remote/doo_client_exception.dart';
import 'package:doo_cx_flutter_sdk_plus/data/remote/requests/doo_action.dart';
import 'package:doo_cx_flutter_sdk_plus/data/remote/requests/doo_action_data.dart';
import 'package:doo_cx_flutter_sdk_plus/data/remote/requests/doo_new_message_request.dart';
import 'package:doo_cx_flutter_sdk_plus/data/remote/service/doo_client_api_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Service for handling DOO api calls
/// See [DOOClientServiceImpl]
abstract class DOOClientService {
  final String _baseUrl;
  WebSocketChannel? connection;
  final Dio _dio;

  DOOClientService(this._baseUrl, this._dio);

  Future<DOOContact> updateContact(update);

  Future<DOOContact> getContact();

  Future<List<DOOConversation>> getConversations();

  Future<DOOMessage> createMessage(DOONewMessageRequest request);

  Future<DOOMessage> updateMessage(String messageIdentifier, update);

  Future<List<DOOMessage>> getAllMessages();

  void startWebSocketConnection(String contactPubsubToken,
      {WebSocketChannel Function(Uri)? onStartConnection});

  void sendAction(String contactPubsubToken, DOOActionType action);
}

class DOOClientServiceImpl extends DOOClientService {
  DOOClientServiceImpl(String baseUrl, {required Dio dio})
      : super(baseUrl, dio);

  ///Sends message to DOO inbox
  @override
  Future<DOOMessage> createMessage(DOONewMessageRequest request) async {
    try {
      final createResponse = await _dio.post(
          "/public/api/v1/inboxes/${DOOClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${DOOClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}/conversations/${DOOClientApiInterceptor.INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER}/messages",
          data: request.toJson());
      if ((createResponse.statusCode ?? 0).isBetween(199, 300)) {
        return DOOMessage.fromJson(createResponse.data);
      } else {
        throw DOOClientException(
            createResponse.statusMessage ?? "unknown error",
            DOOClientExceptionType.SEND_MESSAGE_FAILED);
      }
    } on DioException catch (e) {
      throw DOOClientException(
          e.message!, DOOClientExceptionType.SEND_MESSAGE_FAILED);
    }
  }

  ///Gets all messages of current DOO client instance's conversation
  @override
  Future<List<DOOMessage>> getAllMessages() async {
    try {
      final createResponse = await _dio.get(
          "/public/api/v1/inboxes/${DOOClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${DOOClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}/conversations/${DOOClientApiInterceptor.INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER}/messages");
      if ((createResponse.statusCode ?? 0).isBetween(199, 300)) {
        return (createResponse.data as List<dynamic>)
            .map(((json) => DOOMessage.fromJson(json)))
            .toList();
      } else {
        throw DOOClientException(
            createResponse.statusMessage ?? "unknown error",
            DOOClientExceptionType.GET_MESSAGES_FAILED);
      }
    } on DioException catch (e) {
      throw DOOClientException(
          e.message!, DOOClientExceptionType.GET_MESSAGES_FAILED);
    }
  }

  ///Gets contact of current DOO client instance
  @override
  Future<DOOContact> getContact() async {
    try {
      final createResponse = await _dio.get(
          "/public/api/v1/inboxes/${DOOClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${DOOClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}");
      if ((createResponse.statusCode ?? 0).isBetween(199, 300)) {
        return DOOContact.fromJson(createResponse.data);
      } else {
        throw DOOClientException(
            createResponse.statusMessage ?? "unknown error",
            DOOClientExceptionType.GET_CONTACT_FAILED);
      }
    } on DioException catch (e) {
      throw DOOClientException(
          e.message!, DOOClientExceptionType.GET_CONTACT_FAILED);
    }
  }

  ///Gets all conversation of current DOO client instance
  @override
  Future<List<DOOConversation>> getConversations() async {
    try {
      final createResponse = await _dio.get(
          "/public/api/v1/inboxes/${DOOClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${DOOClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}/conversations");
      if ((createResponse.statusCode ?? 0).isBetween(199, 300)) {
        return (createResponse.data as List<dynamic>)
            .map(((json) => DOOConversation.fromJson(json)))
            .toList();
      } else {
        throw DOOClientException(
            createResponse.statusMessage ?? "unknown error",
            DOOClientExceptionType.GET_CONVERSATION_FAILED);
      }
    } on DioException catch (e) {
      throw DOOClientException(
          e.message!, DOOClientExceptionType.GET_CONVERSATION_FAILED);
    }
  }

  ///Update current client instance's contact
  @override
  Future<DOOContact> updateContact(update) async {
    try {
      final updateResponse = await _dio.patch(
          "/public/api/v1/inboxes/${DOOClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${DOOClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}",
          data: update);
      if ((updateResponse.statusCode ?? 0).isBetween(199, 300)) {
        return DOOContact.fromJson(updateResponse.data);
      } else {
        throw DOOClientException(
            updateResponse.statusMessage ?? "unknown error",
            DOOClientExceptionType.UPDATE_CONTACT_FAILED);
      }
    } on DioException catch (e) {
      throw DOOClientException(
          e.message!, DOOClientExceptionType.UPDATE_CONTACT_FAILED);
    }
  }

  ///Update message with id [messageIdentifier] with contents of [update]
  @override
  Future<DOOMessage> updateMessage(String messageIdentifier, update) async {
    try {
      final updateResponse = await _dio.patch(
          "/public/api/v1/inboxes/${DOOClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${DOOClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}/conversations/${DOOClientApiInterceptor.INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER}/messages/$messageIdentifier",
          data: update);
      if ((updateResponse.statusCode ?? 0).isBetween(199, 300)) {
        return DOOMessage.fromJson(updateResponse.data);
      } else {
        throw DOOClientException(
            updateResponse.statusMessage ?? "unknown error",
            DOOClientExceptionType.UPDATE_MESSAGE_FAILED);
      }
    } on DioException catch (e) {
      throw DOOClientException(
          e.message!, DOOClientExceptionType.UPDATE_MESSAGE_FAILED);
    }
  }

  @override
  void startWebSocketConnection(String contactPubsubToken,
      {WebSocketChannel Function(Uri)? onStartConnection}) {
    final socketUrl = Uri.parse(_baseUrl.replaceFirst("http", "ws") + "/cable");
    this.connection = onStartConnection == null
        ? WebSocketChannel.connect(socketUrl)
        : onStartConnection(socketUrl);
    connection!.sink.add(jsonEncode({
      "command": "subscribe",
      "identifier": jsonEncode(
          {"channel": "RoomChannel", "pubsub_token": contactPubsubToken})
    }));
  }

  @override
  void sendAction(String contactPubsubToken, DOOActionType actionType) {
    final DOOAction action;
    final identifier = jsonEncode(
        {"channel": "RoomChannel", "pubsub_token": contactPubsubToken});
    switch (actionType) {
      case DOOActionType.subscribe:
        action = DOOAction(identifier: identifier, command: "subscribe");
        break;
      default:
        action = DOOAction(
            identifier: identifier,
            data: DOOActionData(action: actionType),
            command: "message");
        break;
    }
    connection?.sink.add(jsonEncode(action.toJson()));
  }
}
