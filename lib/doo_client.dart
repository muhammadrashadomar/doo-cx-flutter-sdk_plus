import 'package:doo_cx_flutter_sdk_plus/data/doo_repository.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/entity/doo_contact.dart';
import 'package:doo_cx_flutter_sdk_plus/data/local/entity/doo_conversation.dart';
import 'package:doo_cx_flutter_sdk_plus/data/remote/requests/doo_action_data.dart';
import 'package:doo_cx_flutter_sdk_plus/data/remote/requests/doo_new_message_request.dart';
import 'package:doo_cx_flutter_sdk_plus/di/modules.dart';
import 'package:doo_cx_flutter_sdk_plus/doo_parameters.dart';
import 'package:doo_cx_flutter_sdk_plus/repository_parameters.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'data/local/entity/doo_user.dart';
import 'data/local/local_storage.dart';
import 'data/remote/doo_client_exception.dart';
import 'doo_callbacks.dart';

/// Represents a DOO client instance for programmatic chat interactions.
///
/// All DOO operations (such as sending messages, loading conversations) are
/// handled through the DOOClient. This class provides a comprehensive API
/// for integrating DOO CX chat functionality into your Flutter application.
///
/// ## Usage
///
/// ```dart
/// final client = await DOOClient.create(
///   baseUrl: "https://your-instance.doo.ooo",
///   inboxIdentifier: "your_inbox_identifier",
///   user: DOOUser(
///     identifier: "user_123",
///     name: "John Doe",
///     email: "john@example.com",
///   ),
///   callbacks: DOOCallbacks(
///     onMessageReceived: (message) => print("New message: ${message.content}"),
///     onError: (error) => print("Error: ${error.cause}"),
///   ),
/// );
///
/// await client.loadMessages();
/// await client.sendMessage(content: "Hello, I need help!");
/// ```
///
/// ## Features
///
/// - **Real-time messaging**: Send and receive messages instantly
/// - **File attachments**: Support for images, documents, and media files
/// - **Message persistence**: Automatic local storage and synchronization
/// - **Error handling**: Comprehensive error reporting and recovery
/// - **Event callbacks**: Respond to message events and connection changes
/// - **Cross-platform**: Works on Android, iOS, and Web
///
/// For more information, visit [DOO CX Documentation](https://www.doo.ooo/docs/product/channels/api/client-apis)
///
/// {@category FlutterClientSdk}
class DOOClient {
  late final DOORepository _repository;
  final DOOParameters _parameters;

  /// Event callbacks for handling chat events and user interactions
  final DOOCallbacks? callbacks;

  /// The user associated with this chat session
  final DOOUser? user;

  final Uuid _uuid = const Uuid();

  /// Get the base URL of the DOO installation
  ///
  /// Example: "https://your-instance.doo.ooo"
  String get baseUrl => _parameters.baseUrl;

  /// Get the inbox identifier for this DOO client
  ///
  /// This is used to connect to a specific inbox in your DOO instance.
  /// You can find this in your DOO dashboard under Settings → Inboxes.
  String? get inboxIdentifier => _parameters.inboxIdentifier;

  /// Get the website token if available (for webview integration)
  ///
  /// Website tokens are used with DOOWidget for webview-based chat.
  /// This is different from inbox identifiers and can be found in
  /// your DOO dashboard under Settings → Inboxes → Website.
  String? get websiteToken => _parameters.websiteToken;

  /// Get the locale setting for localization
  ///
  /// Supports standard locale codes like "en", "es", "fr", etc.
  /// Defaults to "en" if not specified.
  String? get locale => _parameters.locale;

  DOOClient._(this._parameters, {this.user, this.callbacks}) {
    providerContainerMap.putIfAbsent(
        _parameters.clientInstanceKey, () => ProviderContainer());
    final container = providerContainerMap[_parameters.clientInstanceKey]!;
    _repository = container.read(dooRepositoryProvider(RepositoryParameters(
        params: _parameters, callbacks: callbacks ?? DOOCallbacks())));
  }

  void _init() {
    try {
      _repository.initialize(user);
    } on DOOClientException catch (e) {
      callbacks?.onError?.call(e);
    }
  }

  /// Retrieves messages from the DOO conversation.
  ///
  /// This method loads both persisted (cached) messages and fetches new messages
  /// from the server. The process occurs in two stages:
  ///
  /// 1. **Cached Messages**: If persistence is enabled, [DOOCallbacks.onPersistedMessagesRetrieved]
  ///    will be triggered immediately with locally stored messages
  /// 2. **Remote Messages**: [DOOCallbacks.onMessagesRetrieved] will be triggered
  ///    after successfully fetching from the remote server
  ///
  /// ## Example
  ///
  /// ```dart
  /// final client = await DOOClient.create(/* config */);
  /// await client.loadMessages(); // Triggers callback events
  /// ```
  ///
  /// ## Error Handling
  ///
  /// If the request fails, [DOOCallbacks.onError] will be triggered with
  /// the error details.
  Future<void> loadMessages() async {
    _repository.getPersistedMessages();
    await _repository.getMessages();
  }

  /// Sends a text message to the DOO conversation.
  ///
  /// This method sends a message to the active conversation and returns an echo ID
  /// that can be used to track the message status.
  ///
  /// ## Parameters
  ///
  /// - [content]: The message text to send (required)
  /// - [echoId]: Optional unique identifier for tracking. If not provided, a UUID will be generated
  /// - [attachments]: Optional attachments data (currently unused, for future compatibility)
  ///
  /// ## Returns
  ///
  /// Returns the echo ID (String) that can be used to correlate the sent message
  /// with the response in [DOOCallbacks.onMessageSent].
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Simple message
  /// final echoId = await client.sendMessage(content: "Hello, I need help!");
  ///
  /// // Message with custom echo ID
  /// final customEchoId = await client.sendMessage(
  ///   content: "Custom message",
  ///   echoId: "my-unique-id-123"
  /// );
  /// ```
  ///
  /// ## Event Flow
  ///
  /// 1. Message is sent to server
  /// 2. On success: [DOOCallbacks.onMessageSent] is triggered with the [DOOMessage] and echo ID
  /// 3. On failure: [DOOCallbacks.onError] is triggered with error details and echo ID
  ///
  /// ## Error Handling
  ///
  /// If the message fails to send, [DOOCallbacks.onError] will be triggered
  /// with the echo ID included in the error data for correlation.
  Future<String> sendMessage(
      {required String content,
      String? echoId,
      List<String>? attachmentPaths}) async {
    final messageId = echoId ?? _uuid.v4();
    final request = DOONewMessageRequest(
        content: content, echoId: messageId, attachmentPaths: attachmentPaths);
    await _repository.sendMessage(request);
    return messageId;
  }

  /// Sends a user action to the DOO server.
  ///
  /// Actions represent user interactions that help improve the chat experience,
  /// such as typing indicators, message read status, etc.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Indicate user is typing
  /// await client.sendAction(DOOActionType.toggle_typing_on);
  ///
  /// // Indicate user stopped typing
  /// await client.sendAction(DOOActionType.toggle_typing_off);
  /// ```
  ///
  /// ## Available Actions
  ///
  /// - [DOOActionType.toggle_typing_on]: User started typing
  /// - [DOOActionType.toggle_typing_off]: User stopped typing
  ///
  /// ## Parameters
  ///
  /// - [action]: The type of action to send
  Future<void> sendAction(DOOActionType action) async {
    _repository.sendAction(action);
  }

  /// Properly disposes the DOO client and releases all resources.
  ///
  /// This method should be called when the client is no longer needed
  /// to prevent memory leaks and properly close network connections.
  ///
  /// ## What it does
  ///
  /// - Cancels all active stream subscriptions
  /// - Closes WebSocket connections
  /// - Disposes provider containers
  /// - Removes client from memory
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// void dispose() {
  ///   _dooClient?.dispose();
  ///   super.dispose();
  /// }
  /// ```
  ///
  /// ⚠️ **Important**: After calling dispose(), the client instance
  /// should not be used anymore. Create a new instance if needed.
  void dispose() {
    final container = providerContainerMap[_parameters.clientInstanceKey]!;
    _repository.dispose();
    container.dispose();
    providerContainerMap.remove(_parameters.clientInstanceKey);
  }

  /// Clears all DOO client data but preserves user information.
  ///
  /// This method removes conversation history, messages, and cached data
  /// while keeping user profile information intact.
  ///
  /// Useful for scenarios like user logout where you want to clear
  /// conversation data but maintain user preferences.
  Future<void> clearClientData() async {
    final container = providerContainerMap[_parameters.clientInstanceKey]!;
    final localStorage = container.read(localStorageProvider(_parameters));
    await localStorage.clear(clearDOOUserStorage: false);
  }

  /// Clears all DOO client data including user information.
  ///
  /// This method performs a complete data wipe, removing:
  /// - Conversation history
  /// - Messages and attachments
  /// - User profile information
  /// - All cached data
  ///
  /// Use this for complete app resets or when switching between
  /// different user accounts.
  Future<void> clearAllClientData() async {
    final container = providerContainerMap[_parameters.clientInstanceKey]!;
    final localStorage = container.read(localStorageProvider(_parameters));
    await localStorage.clear(clearDOOUserStorage: true);
  }

  /// Creates a new DOOClient instance for programmatic chat interactions.
  ///
  /// This is the primary method for initializing a DOO chat client.
  /// It establishes connection to your DOO instance and sets up
  /// all necessary components for real-time messaging.
  ///
  /// ## Parameters
  ///
  /// ### Required
  /// - [baseUrl]: The base URL of your DOO installation (e.g., "https://app.doo.ooo")
  /// - [inboxIdentifier]: The identifier for the target inbox (found in DOO dashboard)
  ///
  /// ### Optional
  /// - [user]: User information for the chat session
  /// - [enablePersistence]: Whether to cache messages locally (default: true)
  /// - [websiteToken]: Website token for webview integration (optional)
  /// - [locale]: Language locale for chat interface (default: 'en')
  /// - [callbacks]: Event handlers for chat interactions
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Basic setup
  /// final client = await DOOClient.create(
  ///   baseUrl: "https://your-instance.doo.ooo",
  ///   inboxIdentifier: "your_inbox_identifier",
  /// );
  ///
  /// // Advanced setup with user and callbacks
  /// final client = await DOOClient.create(
  ///   baseUrl: "https://your-instance.doo.ooo",
  ///   inboxIdentifier: "your_inbox_identifier",
  ///   user: DOOUser(
  ///     identifier: "user_123",
  ///     name: "John Doe",
  ///     email: "john@example.com",
  ///     customAttributes: {
  ///       "user_type": "premium",
  ///       "signup_date": "2023-01-15",
  ///     },
  ///   ),
  ///   callbacks: DOOCallbacks(
  ///     onMessageReceived: (message) {
  ///       print("New message: ${message.content}");
  ///       NotificationService.show(message.content);
  ///     },
  ///     onError: (error) {
  ///       print("Chat error: ${error.cause}");
  ///       ErrorReporting.log(error);
  ///     },
  ///   ),
  ///   enablePersistence: true,
  ///   locale: "en",
  /// );
  ///
  /// // Load existing messages
  /// await client.loadMessages();
  /// ```
  ///
  /// ## Persistence
  ///
  /// When [enablePersistence] is true (default):
  /// - Messages are cached locally for offline viewing
  /// - User sessions are preserved across app restarts
  /// - Faster initial load times with cached data
  ///
  /// ## Error Handling
  ///
  /// The method may throw [DOOClientException] for:
  /// - Invalid base URL or inbox identifier
  /// - Network connectivity issues
  /// - Authentication failures
  ///
  /// ## Returns
  ///
  /// Returns a configured [DOOClient] instance ready for messaging.
  ///
  /// ⚠️ **Important**: Remember to call [dispose()] when the client
  /// is no longer needed to prevent memory leaks.
  static Future<DOOClient> create(
      {required String baseUrl,
      required String inboxIdentifier,
      DOOUser? user,
      bool enablePersistence = true,
      String? websiteToken,
      String? locale = 'en',
      DOOCallbacks? callbacks}) async {
    if (enablePersistence) {
      await LocalStorage.openDB();
    }

    final dooParams = DOOParameters(
        clientInstanceKey: getClientInstanceKey(
            baseUrl: baseUrl,
            inboxIdentifier: inboxIdentifier,
            userIdentifier: user?.identifier),
        isPersistenceEnabled: enablePersistence,
        baseUrl: baseUrl,
        inboxIdentifier: inboxIdentifier,
        userIdentifier: user?.identifier,
        websiteToken: websiteToken,
        locale: locale);

    final client = DOOClient._(dooParams, callbacks: callbacks, user: user);

    client._init();

    return client;
  }

  static final _keySeparator = "|||";

  ///Create a DOO client instance key using the DOO client instance baseurl, inboxIdentifier
  ///and userIdentifier. Client instance keys are used to differentiate between client instances and their data
  ///(contact ([DOOContact]),conversation ([DOOConversation]) and messages ([DOOMessage]))
  ///
  /// Create separate [DOOClient] instances with same baseUrl, inboxIdentifier, userIdentifier and persistence
  /// enabled will be regarded as same therefore use same contact and conversation.
  static String getClientInstanceKey(
      {required String baseUrl,
      required String inboxIdentifier,
      String? userIdentifier}) {
    return "$baseUrl$_keySeparator$userIdentifier$_keySeparator$inboxIdentifier";
  }

  static Map<String, ProviderContainer> providerContainerMap = {};

  ///Clears all persisted DOO data on device for a particular DOO client instance.
  ///See [getClientInstanceKey] on how DOO client instance are differentiated
  static Future<void> clearData(
      {required String baseUrl,
      required String inboxIdentifier,
      String? userIdentifier}) async {
    final clientInstanceKey = getClientInstanceKey(
        baseUrl: baseUrl,
        inboxIdentifier: inboxIdentifier,
        userIdentifier: userIdentifier);
    providerContainerMap.putIfAbsent(
        clientInstanceKey, () => ProviderContainer());
    final container = providerContainerMap[clientInstanceKey]!;
    final params = DOOParameters(
        isPersistenceEnabled: true,
        baseUrl: "",
        inboxIdentifier: "",
        clientInstanceKey: "");

    final localStorage = container.read(localStorageProvider(params));
    await localStorage.clear();

    localStorage.dispose();
    container.dispose();
    providerContainerMap.remove(clientInstanceKey);
  }

  /// Clears all persisted DOO data on device.
  static Future<void> clearAllData() async {
    providerContainerMap.putIfAbsent("all", () => ProviderContainer());
    final container = providerContainerMap["all"]!;
    final params = DOOParameters(
        isPersistenceEnabled: true,
        baseUrl: "",
        inboxIdentifier: "",
        clientInstanceKey: "");

    final localStorage = container.read(localStorageProvider(params));
    await localStorage.clearAll();

    localStorage.dispose();
    container.dispose();
    providerContainerMap.remove("all");
  }
}
