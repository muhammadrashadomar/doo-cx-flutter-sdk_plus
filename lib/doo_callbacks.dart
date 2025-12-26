import 'package:doo_cx_flutter_sdk_plus/data/doo_repository.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/entity/doo_message.dart';
import 'package:doo_cx_flutter_sdk_plus/data/remote/doo_client_exception.dart';
import 'package:doo_cx_flutter_sdk_plus/data/remote/responses/doo_event.dart';

/// Comprehensive event handlers for DOO chat interactions.
///
/// DOOCallbacks provide a reactive way to handle various events that occur
/// during the lifecycle of a DOO client instance. These callbacks enable you
/// to build responsive UIs, handle real-time updates, and manage errors gracefully.
///
/// ## Usage
///
/// ```dart
/// final callbacks = DOOCallbacks(
///   onWelcome: () {
///     print("Connected to DOO");
///     setState(() => connectionStatus = "Connected");
///   },
///   onMessageReceived: (message) {
///     print("New message: ${message.content}");
///     setState(() => messages.add(message));
///     NotificationService.showNotification(message.content);
///   },
///   onMessageSent: (message, echoId) {
///     print("Message sent: $echoId");
///     // Replace optimistic message with confirmed one
///     updateMessageWithEchoId(echoId, message);
///   },
///   onError: (error) {
///     print("DOO Error: ${error.cause}");
///     showErrorSnackBar(error.cause);
///   },
/// );
///
/// final client = await DOOClient.create(
///   baseUrl: "https://your-instance.doo.ooo",
///   inboxIdentifier: "your_inbox",
///   callbacks: callbacks,
/// );
/// ```
///
/// ## Event Categories
///
/// ### Connection Events
/// - [onWelcome]: Initial connection established
/// - [onPing]: Keepalive ping received
/// - [onConfirmedSubscription]: WebSocket subscription confirmed
///
/// ### Message Events
/// - [onMessageReceived]: New message from agent/bot
/// - [onMessageSent]: Confirmation of sent message
/// - [onMessageUpdated]: Existing message was modified
///
/// ### Conversation State
/// - [onConversationStartedTyping]: Agent is typing
/// - [onConversationStoppedTyping]: Agent stopped typing
/// - [onConversationIsOnline]: Agent is online
/// - [onConversationIsOffline]: Agent went offline
///
/// ### Data Events
/// - [onMessagesRetrieved]: Bulk message load completed
/// - [onPersistedMessagesRetrieved]: Cached messages loaded
///
/// ### Error Handling
/// - [onError]: Any error occurred during operation
///
/// {@category FlutterClientSdk}
class DOOCallbacks {
  /// Triggered when a welcome event is received after connecting to
  /// the DOO websocket. See [DOORepository.listenForEvents]
  final void Function()? onWelcome;

  /// Triggered when a ping event is received after connecting to
  /// the DOO websocket. See [DOORepository.listenForEvents]
  final void Function()? onPing;

  /// Triggered when a subscription confirmation event is received after connecting to
  /// the DOO websocket. See [DOORepository.listenForEvents]
  final void Function()? onConfirmedSubscription;

  /// Triggered when a conversation typing on event [DOOEventMessageType.conversation_typing_on]
  /// is received after connecting to the DOO websocket. See [DOORepository.listenForEvents]
  final void Function()? onConversationStartedTyping;

  /// Triggered when a presence update event [DOOEventMessageType.presence_update]
  /// is received after connecting to the DOO websocket and conversation is online.
  /// See [DOORepository.listenForEvents]
  final void Function()? onConversationIsOnline;

  /// Triggered when a presence update event [DOOEventMessageType.presence_update]
  /// is received after connecting to the DOO websocket and conversation is offline.
  /// See [DOORepository.listenForEvents]
  final void Function()? onConversationIsOffline;

  /// Triggered when a conversation typing off event [DOOEventMessageType.conversation_typing_off]
  /// is received after connecting to the DOO websocket. See [DOORepository.listenForEvents]
  final void Function()? onConversationStoppedTyping;

  /// Triggered when a message created event [DOOEventMessageType.message_created]
  /// is received and message doesn't belong to current user after connecting to the DOO websocket.
  /// See [DOORepository.listenForEvents]
  final void Function(DOOMessage)? onMessageReceived;

  /// Triggered when a message created event [DOOEventMessageType.message_updated]
  /// is received after connecting to the DOO websocket.
  /// See [DOORepository.listenForEvents]
  final void Function(DOOMessage)? onMessageUpdated;

  /// Triggered when a message is sent successfully
  ///
  /// [message] is the sent message
  /// [echoId] is the temporary ID used to track the message
  final void Function(DOOMessage, String)? onMessageSent;

  /// Triggered when a message created event [DOOEventMessageType.message_created]
  /// is received and message belongs to current user after connecting to the DOO websocket.
  /// See [DOORepository.listenForEvents]
  final void Function(DOOMessage, String)? onMessageDelivered;

  /// Triggered when a conversation's messages persisted on device are successfully retrieved
  final void Function(List<DOOMessage>)? onPersistedMessagesRetrieved;

  /// Triggered when a conversation's messages is successfully retrieved from remote server
  final void Function(List<DOOMessage>)? onMessagesRetrieved;

  /// Triggered when an agent resolves the current conversation
  final void Function()? onConversationResolved;

  /// Triggered when a file is being uploaded
  final void Function(double)? onFileUploadProgress;

  /// Triggered when a file is successfully uploaded
  final void Function(Map<String, dynamic>)? onFileUploadSuccess;

  /// Triggered when any error occurs in DOO client's operations with the error
  ///
  /// See [DOOClientExceptionType] for the various types of exceptions that can be triggered
  final void Function(DOOClientException)? onError;

  /// Creates a new DOOCallbacks instance with specified callback handlers
  DOOCallbacks({
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
    this.onConversationResolved,
    this.onFileUploadProgress,
    this.onFileUploadSuccess,
    this.onError,
  });
}
