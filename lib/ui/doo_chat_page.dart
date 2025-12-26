import 'package:doo_cx_flutter_sdk_plus/doo_callbacks.dart';
import 'package:doo_cx_flutter_sdk_plus/doo_client.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/entity/doo_message.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/entity/doo_user.dart';
import 'package:doo_cx_flutter_sdk_plus/data/remote/doo_client_exception.dart';
import 'package:doo_cx_flutter_sdk_plus/ui/doo_chat_theme.dart';
import 'package:doo_cx_flutter_sdk_plus/ui/doo_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

///DOO chat widget
/// {@category FlutterClientSdk}
class DOOChat extends StatefulWidget {
  /// Specifies a custom app bar for DOO page widget
  final PreferredSizeWidget? appBar;

  ///Installation url for DOO
  final String baseUrl;

  ///Identifier for target DOO inbox.
  ///
  /// For more details see https://www.doo.ooo/docs/product/channels/api/client-apis
  final String inboxIdentifier;

  /// Enables persistence of DOO client instance's contact, conversation and messages to disk
  /// for convenience.
  ///
  /// Setting [enablePersistence] to false holds DOO client instance's data in memory and is cleared as
  /// soon as DOO client instance is disposed
  final bool enablePersistence;

  /// Custom user details to be attached to DOO contact
  final DOOUser? user;

  /// See [ChatList.onEndReached]
  final Future<void> Function()? onEndReached;

  /// See [ChatList.onEndReachedThreshold]
  final double? onEndReachedThreshold;

  /// See [Message.onMessageLongPress]
  final void Function(BuildContext context, types.Message)? onMessageLongPress;

  /// See [Message.onMessageTap]
  final void Function(types.Message)? onMessageTap;

  /// See [Input.onSendPressed]
  final void Function(types.PartialText)? onSendPressed;

  /// See [Input.onTextChanged]
  final void Function(String)? onTextChanged;

  /// Show avatars for received messages.
  final bool showUserAvatars;

  /// Show user names for received messages.
  final bool showUserNames;

  final DOOChatTheme theme;

  /// See [DOOL10n]
  final DOOL10n l10n;

  /// See [Chat.timeFormat]
  final DateFormat? timeFormat;

  /// See [Chat.dateFormat]
  final DateFormat? dateFormat;

  ///See [DOOCallbacks.onWelcome]
  final void Function()? onWelcome;

  ///See [DOOCallbacks.onPing]
  final void Function()? onPing;

  ///See [DOOCallbacks.onConfirmedSubscription]
  final void Function()? onConfirmedSubscription;

  ///See [DOOCallbacks.onConversationStartedTyping]
  final void Function()? onConversationStartedTyping;

  ///See [DOOCallbacks.onConversationIsOnline]
  final void Function()? onConversationIsOnline;

  ///See [DOOCallbacks.onConversationIsOffline]
  final void Function()? onConversationIsOffline;

  ///See [DOOCallbacks.onConversationStoppedTyping]
  final void Function()? onConversationStoppedTyping;

  ///See [DOOCallbacks.onMessageReceived]
  final void Function(DOOMessage)? onMessageReceived;

  ///See [DOOCallbacks.onMessageSent]
  final void Function(DOOMessage)? onMessageSent;

  ///See [DOOCallbacks.onMessageDelivered]
  final void Function(DOOMessage)? onMessageDelivered;

  ///See [DOOCallbacks.onMessageUpdated]
  final void Function(DOOMessage)? onMessageUpdated;

  ///See [DOOCallbacks.onPersistedMessagesRetrieved]
  final void Function(List<DOOMessage>)? onPersistedMessagesRetrieved;

  ///See [DOOCallbacks.onMessagesRetrieved]
  final void Function(List<DOOMessage>)? onMessagesRetrieved;

  ///See [DOOCallbacks.onError]
  final void Function(DOOClientException)? onError;

  ///Horizontal padding is reduced if set to true
  final bool isPresentedInDialog;

  const DOOChat(
      {Key? key,
      required this.baseUrl,
      required this.inboxIdentifier,
      this.enablePersistence = true,
      this.user,
      this.appBar,
      this.onEndReached,
      this.onEndReachedThreshold,
      this.onMessageLongPress,
      this.onMessageTap,
      this.onSendPressed,
      this.onTextChanged,
      this.showUserAvatars = true,
      this.showUserNames = true,
      this.theme = const DOOChatTheme(),
      this.l10n = const DOOL10n(),
      this.timeFormat,
      this.dateFormat,
      this.onWelcome,
      this.onPing,
      this.onConfirmedSubscription,
      this.onMessageReceived,
      this.onMessageSent,
      this.onMessageDelivered,
      this.onMessageUpdated,
      this.onPersistedMessagesRetrieved,
      this.onMessagesRetrieved,
      this.onConversationStartedTyping,
      this.onConversationStoppedTyping,
      this.onConversationIsOnline,
      this.onConversationIsOffline,
      this.onError,
      this.isPresentedInDialog = false})
      : super(key: key);

  @override
  _DOOChatState createState() => _DOOChatState();
}

class _DOOChatState extends State<DOOChat> {
  ///
  List<types.Message> _messages = [];

  late String status;

  final idGen = Uuid();
  late final _user;
  DOOClient? dooClient;

  late final dooCallbacks;

  @override
  void initState() {
    super.initState();

    if (widget.user == null) {
      _user = types.User(id: idGen.v4());
    } else {
      _user = types.User(
        id: widget.user?.identifier ?? idGen.v4(),
        firstName: widget.user?.name,
        imageUrl: widget.user?.avatarUrl,
      );
    }

    dooCallbacks = DOOCallbacks(
      onWelcome: () {
        widget.onWelcome?.call();
      },
      onPing: () {
        widget.onPing?.call();
      },
      onConfirmedSubscription: () {
        widget.onConfirmedSubscription?.call();
      },
      onConversationStartedTyping: () {
        widget.onConversationStoppedTyping?.call();
      },
      onConversationStoppedTyping: () {
        widget.onConversationStartedTyping?.call();
      },
      onPersistedMessagesRetrieved: (persistedMessages) {
        if (widget.enablePersistence) {
          setState(() {
            _messages = persistedMessages
                .map((message) => _dooMessageToTextMessage(message))
                .toList();
          });
        }
        widget.onPersistedMessagesRetrieved?.call(persistedMessages);
      },
      onMessagesRetrieved: (messages) {
        if (messages.isEmpty) {
          return;
        }
        setState(() {
          final chatMessages = messages
              .map((message) => _dooMessageToTextMessage(message))
              .toList();
          final mergedMessages =
              <types.Message>[..._messages, ...chatMessages].toSet().toList();
          final now = DateTime.now().millisecondsSinceEpoch;
          mergedMessages.sort((a, b) {
            return (b.createdAt ?? now).compareTo(a.createdAt ?? now);
          });
          _messages = mergedMessages;
        });
        widget.onMessagesRetrieved?.call(messages);
      },
      onMessageReceived: (dooMessage) {
        _addMessage(_dooMessageToTextMessage(dooMessage));
        widget.onMessageReceived?.call(dooMessage);
      },
      onMessageDelivered: (dooMessage, echoId) {
        _handleMessageSent(
            _dooMessageToTextMessage(dooMessage, echoId: echoId));
        widget.onMessageDelivered?.call(dooMessage);
      },
      onMessageUpdated: (dooMessage) {
        _handleMessageUpdated(_dooMessageToTextMessage(dooMessage,
            echoId: dooMessage.id.toString()));
        widget.onMessageUpdated?.call(dooMessage);
      },
      onMessageSent: (dooMessage, echoId) {
        final textMessage = types.TextMessage(
            id: echoId,
            author: _user,
            text: dooMessage.content ?? "",
            status: types.Status.delivered);
        _handleMessageSent(textMessage);
        widget.onMessageSent?.call(dooMessage);
      },
      onConversationResolved: () {
        final resolvedMessage = types.TextMessage(
            id: idGen.v4(),
            text: widget.l10n.conversationResolvedMessage,
            author: types.User(
                id: idGen.v4(),
                firstName: "Bot",
                imageUrl:
                    "https://d2cbg94ubxgsnp.cloudfront.net/Pictures/480x270//9/9/3/512993_shutterstock_715962319converted_920340.png"),
            status: types.Status.delivered);
        _addMessage(resolvedMessage);
      },
      onError: (error) {
        if (error.type == DOOClientExceptionType.SEND_MESSAGE_FAILED) {
          _handleSendMessageFailed(error.data);
        }
        print("Ooops! Something went wrong. Error Cause: ${error.cause}");
        widget.onError?.call(error);
      },
    );

    DOOClient.create(
            baseUrl: widget.baseUrl,
            inboxIdentifier: widget.inboxIdentifier,
            user: widget.user,
            enablePersistence: widget.enablePersistence,
            callbacks: dooCallbacks)
        .then((client) {
      setState(() {
        dooClient = client;
        dooClient!.loadMessages();
      });
    }).onError((error, stackTrace) {
      widget.onError?.call(DOOClientException(
          error.toString(), DOOClientExceptionType.CREATE_CLIENT_FAILED));
      print("DOO client failed with error $error: $stackTrace");
    });
  }

  types.TextMessage _dooMessageToTextMessage(DOOMessage message,
      {String? echoId}) {
    String? avatarUrl = message.sender?.avatarUrl ?? message.sender?.thumbnail;

    //Sets avatar url to null if its a gravatar not found url
    //This enables placeholder for avatar to show
    if (avatarUrl?.contains("?d=404") ?? false) {
      avatarUrl = null;
    }
    return types.TextMessage(
        id: echoId ?? message.id.toString(),
        author: message.isMine
            ? _user
            : types.User(
                id: message.sender?.id.toString() ?? idGen.v4(),
                firstName: message.sender?.name,
                imageUrl: avatarUrl,
              ),
        text: message.content ?? "",
        status: types.Status.seen,
        createdAt: DateTime.parse(message.createdAt).millisecondsSinceEpoch);
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendMessageFailed(String echoId) async {
    final index = _messages.indexWhere((element) => element.id == echoId);
    setState(() {
      _messages[index] = _messages[index].copyWith(status: types.Status.error);
    });
  }

  void _handleResendMessage(types.TextMessage message) async {
    dooClient!.sendMessage(content: message.text, echoId: message.id);
    final index = _messages.indexWhere((element) => element.id == message.id);
    setState(() {
      _messages[index] = message.copyWith(status: types.Status.sending);
    });
  }

  void _handleMessageTap(BuildContext Context, types.Message message) async {
    if (message.status == types.Status.error && message is types.TextMessage) {
      _handleResendMessage(message);
    }
    widget.onMessageTap?.call(message);
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = _messages[index].copyWith();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = updatedMessage;
      });
    });
  }

  void _handleMessageSent(
    types.Message message,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);

    if (_messages[index].status == types.Status.seen) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = message;
      });
    });
  }

  void _handleMessageUpdated(
    types.Message message,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = message;
      });
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: message.text,
        status: types.Status.sending);

    _addMessage(textMessage);

    dooClient!.sendMessage(content: textMessage.text, echoId: textMessage.id);
    widget.onSendPressed?.call(message);
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = widget.isPresentedInDialog ? 8.0 : 16.0;
    return Scaffold(
      appBar: widget.appBar,
      backgroundColor: widget.theme.backgroundColor,
      body: Column(
        children: [
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(
                  left: horizontalPadding, right: horizontalPadding),
              child: Chat(
                messages: _messages,
                onMessageTap: _handleMessageTap,
                onPreviewDataFetched: _handlePreviewDataFetched,
                onSendPressed: _handleSendPressed,
                user: _user,
                onEndReached: widget.onEndReached,
                onEndReachedThreshold: widget.onEndReachedThreshold,
                onMessageLongPress: widget.onMessageLongPress,
                // onTextChanged: widget.onTextChanged,
                showUserAvatars: widget.showUserAvatars,
                showUserNames: widget.showUserNames,
                timeFormat: widget.timeFormat ?? DateFormat.Hm(),
                dateFormat: widget.timeFormat ?? DateFormat("EEEE MMMM d"),
                theme: widget.theme,
                l10n: widget.l10n,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/doo-logo.png",
                  package: 'doo_cx_flutter_sdk_plus',
                  width: 15,
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Powered by DOO",
                    style: TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    dooClient?.dispose();
  }
}
