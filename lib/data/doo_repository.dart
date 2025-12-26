import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:doo_cx_flutter_sdk_plus/doo_callbacks.dart';
import 'package:doo_cx_flutter_sdk_plus/doo_client.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/entity/doo_user.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/local_storage.dart';
import 'package:doo_cx_flutter_sdk_plus/data/remote/doo_client_exception.dart';
import 'package:doo_cx_flutter_sdk_plus/data/remote/requests/doo_action_data.dart';
import 'package:doo_cx_flutter_sdk_plus/data/remote/requests/doo_new_message_request.dart';
import 'package:doo_cx_flutter_sdk_plus/data/remote/responses/doo_event.dart';
import 'package:doo_cx_flutter_sdk_plus/data/remote/service/doo_client_service.dart';
import 'package:flutter/material.dart';

/// Handles interactions between DOO client api service[clientService] and
/// [localStorage] if persistence is enabled.
///
/// Results from repository operations are passed through [callbacks] to be handled
/// appropriately
abstract class DOORepository {
  @protected
  final DOOClientService clientService;
  @protected
  final LocalStorage localStorage;
  @protected
  DOOCallbacks callbacks;
  List<StreamSubscription> _subscriptions = [];

  DOORepository(this.clientService, this.localStorage, this.callbacks);

  Future<void> initialize(DOOUser? user);

  void getPersistedMessages();

  Future<void> getMessages();

  void listenForEvents();

  Future<void> sendMessage(DOONewMessageRequest request);

  void sendAction(DOOActionType action);

  Future<void> clear();

  void dispose();
}

class DOORepositoryImpl extends DOORepository {
  bool _isListeningForEvents = false;
  Timer? _publishPresenceTimer;
  Timer? _presenceResetTimer;

  DOORepositoryImpl(
      {required DOOClientService clientService,
      required LocalStorage localStorage,
      required DOOCallbacks streamCallbacks})
      : super(clientService, localStorage, streamCallbacks);

  /// Fetches persisted messages.
  ///
  /// Calls [DOOCallbacks.onMessagesRetrieved] when [DOOClientService.getAllMessages] is successful
  /// Calls [DOOCallbacks.onError] when [DOOClientService.getAllMessages] fails
  @override
  Future<void> getMessages() async {
    try {
      final messages = await clientService.getAllMessages();
      await localStorage.messagesDao.saveAllMessages(messages);
      callbacks.onMessagesRetrieved?.call(messages);
    } on DOOClientException catch (e) {
      callbacks.onError?.call(e);
    }
  }

  /// Fetches persisted messages.
  ///
  /// Calls [DOOCallbacks.onPersistedMessagesRetrieved] if persisted messages are found
  @override
  void getPersistedMessages() {
    final persistedMessages = localStorage.messagesDao.getMessages();
    if (persistedMessages.isNotEmpty) {
      callbacks.onPersistedMessagesRetrieved?.call(persistedMessages);
    }
  }

  /// Initializes DOO client repository
  Future<void> initialize(DOOUser? user) async {
    try {
      if (user != null) {
        await localStorage.userDao.saveUser(user);
      }

      //refresh contact
      final contact = await clientService.getContact();
      localStorage.contactDao.saveContact(contact);

      //refresh conversation
      final conversations = await clientService.getConversations();
      final persistedConversation =
          localStorage.conversationDao.getConversation()!;
      final refreshedConversation = conversations.firstWhere(
          (element) => element.id == persistedConversation.id,
          orElse: () =>
              persistedConversation //highly unlikely orElse will be called but still added it just in case
          );
      localStorage.conversationDao.saveConversation(refreshedConversation);
    } on DOOClientException catch (e) {
      callbacks.onError?.call(e);
    }

    listenForEvents();
  }

  ///Sends message to DOO inbox
  Future<void> sendMessage(DOONewMessageRequest request) async {
    try {
      final createdMessage = await clientService.createMessage(request);
      await localStorage.messagesDao.saveMessage(createdMessage);
      callbacks.onMessageSent?.call(createdMessage, request.echoId);
      if (clientService.connection != null && !_isListeningForEvents) {
        listenForEvents();
      }
    } on DOOClientException catch (e) {
      callbacks.onError
          ?.call(DOOClientException(e.cause, e.type, data: request.echoId));
    }
  }

  /// Connects to DOO websocket and starts listening for updates
  ///
  /// Received events/messages are pushed through [DOOClient.callbacks]
  @override
  void listenForEvents() {
    final token = localStorage.contactDao.getContact()?.pubsubToken;
    if (token == null) {
      return;
    }
    clientService.startWebSocketConnection(
        localStorage.contactDao.getContact()!.pubsubToken ?? "");

    final newSubscription = clientService.connection!.stream.listen((event) {
      DOOEvent dooEvent = DOOEvent.fromJson(jsonDecode(event));
      if (dooEvent.type == DOOEventType.welcome) {
        callbacks.onWelcome?.call();
      } else if (dooEvent.type == DOOEventType.ping) {
        callbacks.onPing?.call();
      } else if (dooEvent.type == DOOEventType.confirm_subscription) {
        if (!_isListeningForEvents) {
          _isListeningForEvents = true;
        }
        _publishPresenceUpdates();
        callbacks.onConfirmedSubscription?.call();
      } else if (dooEvent.message?.event ==
          DOOEventMessageType.message_created) {
        print("here comes message: $event");
        final message = dooEvent.message!.data!.getMessage();
        localStorage.messagesDao.saveMessage(message);
        if (message.isMine) {
          callbacks.onMessageDelivered
              ?.call(message, dooEvent.message!.data!.echoId!);
        } else {
          callbacks.onMessageReceived?.call(message);
        }
      } else if (dooEvent.message?.event ==
          DOOEventMessageType.message_updated) {
        print("here comes the updated message: $event");

        final message = dooEvent.message!.data!.getMessage();
        localStorage.messagesDao.saveMessage(message);

        callbacks.onMessageUpdated?.call(message);
      } else if (dooEvent.message?.event ==
          DOOEventMessageType.conversation_typing_off) {
        callbacks.onConversationStoppedTyping?.call();
      } else if (dooEvent.message?.event ==
          DOOEventMessageType.conversation_typing_on) {
        callbacks.onConversationStartedTyping?.call();
      } else if (dooEvent.message?.event ==
              DOOEventMessageType.conversation_status_changed &&
          dooEvent.message?.data?.status == "resolved" &&
          dooEvent.message?.data?.id ==
              (localStorage.conversationDao.getConversation()?.id ?? 0)) {
        //delete conversation result
        localStorage.conversationDao.deleteConversation();
        localStorage.messagesDao.clear();
        callbacks.onConversationResolved?.call();
      } else if (dooEvent.message?.event ==
          DOOEventMessageType.presence_update) {
        final presenceStatuses =
            (dooEvent.message!.data!.users as Map<dynamic, dynamic>).values;
        final isOnline = presenceStatuses.contains("online");
        if (isOnline) {
          callbacks.onConversationIsOnline?.call();
          _presenceResetTimer?.cancel();
          _startPresenceResetTimer();
        } else {
          callbacks.onConversationIsOffline?.call();
        }
      } else {
        print("DOO unknown event: $event");
      }
    });
    _subscriptions.add(newSubscription);
  }

  /// Clears all data related to current DOO client instance
  @override
  Future<void> clear() async {
    await localStorage.clear();
  }

  /// Cancels websocket stream subscriptions and disposes [localStorage]
  @override
  void dispose() {
    localStorage.dispose();
    callbacks = DOOCallbacks();
    _presenceResetTimer?.cancel();
    _publishPresenceTimer?.cancel();
    _subscriptions.forEach((subs) {
      subs.cancel();
    });
  }

  ///Send actions like user started typing
  @override
  void sendAction(DOOActionType action) {
    clientService.sendAction(
        localStorage.contactDao.getContact()!.pubsubToken ?? "", action);
  }

  ///Publishes presence update to websocket channel at a 30 second interval
  void _publishPresenceUpdates() {
    sendAction(DOOActionType.update_presence);
    _publishPresenceTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      sendAction(DOOActionType.update_presence);
    });
  }

  ///Triggers an offline presence event after 40 seconds without receiving a presence update event
  void _startPresenceResetTimer() {
    _presenceResetTimer = Timer.periodic(Duration(seconds: 40), (timer) {
      callbacks.onConversationIsOffline?.call();
      _presenceResetTimer?.cancel();
    });
  }
}
