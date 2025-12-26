# DOO CX Flutter SDK - Complete Integration Guide

[![Pub Version](https://img.shields.io/pub/v/doo_cx_flutter_sdk_plus?color=blueviolet)](https://pub.dev/packages/doo_cx_flutter_sdk_plus)
[![Documentation](https://img.shields.io/badge/docs-latest-brightgreen.svg)](https://pub.dev/documentation/doo_cx_flutter_sdk_plus/latest/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A comprehensive Flutter package to integrate DOO CX into your mobile and web applications for Android, iOS, and Web. [DOO CX](https://www.doo.ooo) helps businesses automate routine tasks, optimize sales and customer service processes, and provide personalized interactions by seamlessly integrating AI with existing tools and workflows.

<p align="center">
  <img src="https://raw.githubusercontent.com/doo-inc/doo-cx-flutter-sdk/main/assets/logo_grey.jpg" width="300" alt="DOO CX">
</p>

## ✨ Features

- 🚀 **4 Integration Methods** - Choose the best approach for your app
- 🎨 **Fully Customizable** - Themes, colors, callbacks, and behavior
- 📱 **Cross-Platform** - Android, iOS, and Web support
- 🔄 **Real-time Messaging** - Instant message synchronization
- 📎 **File Attachments** - Support for images, documents, and media
- 🌐 **Internationalization** - Built-in localization support
- 🔧 **TypeScript Support** - Full type safety and autocompletion
- ⚡ **Performance Optimized** - Efficient memory usage and fast rendering

## 📋 Table of Contents

- [🚀 Quick Start](#-quick-start)
- [📦 Installation](#-installation)
- [🔧 Setup](#-setup)
- [🛠️ Integration Methods](#️-integration-methods)
  - [Method 1: DOOWidget (Webview)](#method-1-doowidget-webview)
  - [Method 2: DOO Chat Dialog](#method-2-doo-chat-dialog)
  - [Method 3: DOO Chat Page](#method-3-doo-chat-page)
  - [Method 4: DOOClient (Custom Implementation)](#method-4-dooclient-custom-implementation)
- [🎨 Customization](#-customization)
- [📱 Platform Support](#-platform-support)
- [🔧 Advanced Configuration](#-advanced-configuration)
- [📖 API Reference](#-api-reference)
- [💡 Best Practices](#-best-practices)
- [🐛 Troubleshooting](#-troubleshooting)
- [📚 Examples](#-examples)

## 🚀 Quick Start

Get up and running with DOO CX in under 5 minutes:

```bash
# 1. Add to your project
flutter pub add doo_cx_flutter_sdk_plus

# 2. Import the package
import 'package:doo_cx_flutter_sdk_plus/doo_cx_flutter_sdk_plus.dart';

# 3. Add a simple widget
DOOWidget(
  websiteToken: "your_website_token",
  baseUrl: "https://your-doo-instance.com",
)
```

## 📦 Installation

### Option 1: Command Line (Recommended)

```bash
flutter pub add doo_cx_flutter_sdk_plus
```

### Option 2: Manual Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  doo_cx_flutter_sdk_plus: ^1.1.0
```

Then run:

```bash
flutter pub get
```

### Import the Package

```dart
import 'package:doo_cx_flutter_sdk_plus/doo_cx_flutter_sdk_plus.dart';
```

## 🔧 Setup

### Prerequisites

1. **DOO CX Account**: Sign up at [doo.ooo](https://www.doo.ooo)
2. **Flutter Environment**: Ensure Flutter 3.0+ is installed
3. **DOO Instance**: Have your DOO CX instance URL ready

### Getting Your Credentials

1. Log into your DOO CX dashboard
2. Navigate to Settings → Inboxes
3. Select or create an inbox
4. Copy the **Website Token** or **Inbox Identifier**
5. Note your **Instance URL** (e.g., `https://app.doo.ooo`)

## 🛠️ Integration Methods

The DOO CX Flutter SDK provides 4 flexible integration methods to suit different app architectures and use cases.

### Method 1: DOOWidget (Webview)

**Best for**: Quick integration with full DOO web interface

**Platforms**: ✅ Android ✅ iOS ⚠️ Web (with limitations)

```dart
import 'package:flutter/material.dart';
import 'package:doo_cx_flutter_sdk_plus/doo_cx_flutter_sdk_plus.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customer Support')),
      body: DOOWidget(
        websiteToken: "your_website_token_here",
        baseUrl: "https://your-doo-instance.com",
        user: DOOUser(
          identifier: "user_123",
          name: "John Doe",
          email: "john@example.com",
        ),
        customAttributes: {
          "premium_user": true,
          "app_version": "1.0.0",
        },
        onAttachFile: () async {
          // Handle file attachments
          return ["path/to/selected/file.jpg"];
        },
        onLoadStarted: () => print("Chat loading..."),
        onLoadCompleted: () => print("Chat loaded!"),
      ),
    );
  }
}
```

### Method 2: DOO Chat Dialog

**Best for**: Modal chat overlays and floating chat windows

**Platforms**: ✅ Android ✅ iOS ✅ Web

```dart
import 'package:flutter/material.dart';
import 'package:doo_cx_flutter_sdk_plus/doo_cx_flutter_sdk_plus.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('My App')),
        body: YourAppContent(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showChatDialog(context),
          child: Icon(Icons.chat),
        ),
      ),
    );
  }

  void _showChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DOOChatDialog(
        websiteToken: "your_website_token_here",
        baseUrl: "https://your-doo-instance.com",
        user: DOOUser(
          identifier: "user_123",
          name: "John Doe",
          email: "john@example.com",
        ),
        // Customization options
        theme: DOOChatTheme(
          primaryColor: Colors.blue,
          backgroundColor: Colors.white,
          userMessageTextColor: Colors.white,
          botMessageTextColor: Colors.black87,
        ),
        l10n: DOOLocalizations(
          sendMessagePlaceholder: "Type your message...",
          onlineText: "We're online!",
          offlineText: "We're away. Leave a message!",
        ),
      ),
    );
  }
}
```

### Method 3: DOO Chat Page

**Best for**: Dedicated chat screens and full-page chat experiences

**Platforms**: ✅ Android ✅ iOS ✅ Web

```dart
import 'package:flutter/material.dart';
import 'package:doo_cx_flutter_sdk_plus/doo_cx_flutter_sdk_plus.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DOOChatPage(
      websiteToken: "your_website_token_here", 
      baseUrl: "https://your-doo-instance.com",
      user: DOOUser(
        identifier: "user_123",
        name: "John Doe",
        email: "john@example.com",
        avatarUrl: "https://example.com/avatar.jpg",
      ),
      // Advanced customization
      appBar: AppBar(
        title: Text('Customer Support'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.phone),
            onPressed: () => _initiateCall(),
          ),
        ],
      ),
      theme: DOOChatTheme(
        primaryColor: Colors.blue,
        backgroundColor: Colors.grey[50],
        userMessageBackgroundColor: Colors.blue,
        botMessageBackgroundColor: Colors.white,
        messageTextStyle: TextStyle(fontSize: 16),
        timestampTextStyle: TextStyle(fontSize: 12, color: Colors.grey),
      ),
      enableAttachments: true,
      showUserNames: true,
      showUserAvatars: true,
      onAttachFile: () async {
        // Custom file picker implementation
        final picker = ImagePicker();
        final image = await picker.pickImage(source: ImageSource.gallery);
        return image != null ? [image.path] : [];
      },
    );
  }

  void _initiateCall() {
    // Handle call functionality
  }
}
```

### Method 4: DOOClient (Custom Implementation)

**Best for**: Complete control over UI/UX with custom chat interfaces

**Platforms**: ✅ Android ✅ iOS ✅ Web

```dart
import 'package:flutter/material.dart';
import 'package:doo_cx_flutter_sdk_plus/doo_cx_flutter_sdk_plus.dart';

class CustomChatScreen extends StatefulWidget {
  @override
  _CustomChatScreenState createState() => _CustomChatScreenState();
}

class _CustomChatScreenState extends State<CustomChatScreen> {
  DOOClient? _client;
  List<DOOMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = true;
  String _statusMessage = "Connecting...";

  @override
  void initState() {
    super.initState();
    _initDOOClient();
  }

  Future<void> _initDOOClient() async {
    try {
      _client = await DOOClient.create(
        baseUrl: "https://your-doo-instance.com",
        inboxIdentifier: "your_inbox_identifier",
        user: DOOUser(
          identifier: "user_123",
          name: "John Doe",
          email: "john@example.com",
        ),
        callbacks: DOOCallbacks(
          onWelcome: () {
            setState(() => _statusMessage = "Connected");
          },
          onMessageReceived: (message) {
            setState(() => _messages.add(message));
          },
          onMessageSent: (message, echoId) {
            // Replace optimistic message with real one
            setState(() {
              _messages.removeWhere((msg) => msg.content == message.content && msg.id < 0);
              _messages.add(message);
            });
          },
          onMessagesRetrieved: (messages) {
            setState(() {
              _messages = messages;
              _isLoading = false;
            });
          },
          onPersistedMessagesRetrieved: (messages) {
            setState(() => _messages = messages);
          },
          onError: (error) {
            setState(() => _statusMessage = "Error: ${error.cause}");
          },
        ),
      );
      
      await _client!.loadMessages();
    } catch (e) {
      setState(() => _statusMessage = "Failed to initialize: $e");
    }
  }

  Future<void> _sendMessage() async {
    if (_textController.text.isNotEmpty && _client != null) {
      final content = _textController.text;
      _textController.clear();
      
      // Optimistic UI update
      final optimisticMessage = DOOMessage(
        id: -DateTime.now().millisecondsSinceEpoch,
        content: content,
        messageType: 0,
        contentType: "text",
        contentAttributes: {},
        createdAt: DateTime.now().toIso8601String(),
        conversationId: 0,
        attachments: [],
        sender: null,
      );
      
      setState(() => _messages.add(optimisticMessage));
      
      try {
        await _client!.sendMessage(content: content);
      } catch (e) {
        // Remove optimistic message on failure
        setState(() => _messages.removeWhere((msg) => msg.id < 0));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Chat'),
        subtitle: Text(_statusMessage),
      ),
      body: Column(
        children: [
          // Connection status indicator
          if (_isLoading)
            LinearProgressIndicator(),
          
          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? Center(child: Text('No messages yet'))
                : ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message.isMine;
                      
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.content ?? '',
                                style: TextStyle(
                                  color: isUser ? Colors.white : Colors.black,
                                ),
                              ),
                              if (message.attachments.isNotEmpty)
                                ...message.attachments.map((attachment) => 
                                  Image.network(attachment.dataUrl, height: 200)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Message input
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file),
                  onPressed: _attachFile,
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _attachFile() async {
    // Implement file attachment logic
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // Upload file via DOOClient
        // await _client!.sendAttachment(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to attach file: $e')),
      );
    }
  }

  @override
  void dispose() {
    _client?.dispose();
    _textController.dispose();
    super.dispose();
  }
}
```

## 🎨 Customization

### Theme Customization

Create custom themes to match your app's design:

```dart
DOOChatTheme customTheme = DOOChatTheme(
  // Primary colors
  primaryColor: Color(0xFF6C5CE7),
  backgroundColor: Color(0xFFF8F9FA),
  
  // Message colors
  userMessageBackgroundColor: Color(0xFF6C5CE7),
  userMessageTextColor: Colors.white,
  botMessageBackgroundColor: Colors.white,
  botMessageTextColor: Color(0xFF2D3436),
  
  // Typography
  messageTextStyle: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  ),
  timestampTextStyle: TextStyle(
    fontSize: 12,
    color: Color(0xFF636E72),
  ),
  
  // Input field
  inputBackgroundColor: Colors.white,
  inputTextColor: Color(0xFF2D3436),
  inputBorderColor: Color(0xFFDDD6FE),
  
  // Status indicators
  onlineIndicatorColor: Color(0xFF00B894),
  offlineIndicatorColor: Color(0xFFE17055),
  
  // Attachments
  attachmentIconColor: Color(0xFF636E72),
  attachmentBackgroundColor: Color(0xFFF1F3F4),
);
```

### Localization

Customize text strings for different languages:

```dart
DOOLocalizations customL10n = DOOLocalizations(
  // Message input
  sendMessagePlaceholder: "Escribe tu mensaje...",
  
  // Status messages
  onlineText: "¡Estamos en línea!",
  offlineText: "No disponible. ¡Deja un mensaje!",
  
  // Actions
  sendButtonText: "Enviar",
  attachmentButtonText: "Adjuntar",
  
  // Error messages
  connectionErrorText: "Error de conexión",
  messageFailedText: "Mensaje fallido",
  
  // File attachments
  fileAttachmentText: "Archivo adjunto",
  imageAttachmentText: "Imagen",
  
  // Timestamps
  todayText: "Hoy",
  yesterdayText: "Ayer",
);
```

### Advanced Callbacks

Implement comprehensive event handling:

```dart
DOOCallbacks callbacks = DOOCallbacks(
  onWelcome: () {
    print("Chat session started");
    // Analytics tracking
    analytics.track('chat_session_started');
  },
  
  onMessageReceived: (message) {
    print("New message: ${message.content}");
    // Show notification
    NotificationService.showNotification(
      title: "New message",
      body: message.content,
    );
  },
  
  onMessageSent: (message, echoId) {
    print("Message sent: $echoId");
    // Update UI state
    updateMessageState(message, echoId);
  },
  
  onMessagesRetrieved: (messages) {
    print("Loaded ${messages.length} messages");
    // Cache messages locally
    MessageCache.store(messages);
  },
  
  onPersistedMessagesRetrieved: (messages) {
    print("Restored ${messages.length} cached messages");
  },
  
  onError: (error) {
    print("DOO Error: ${error.cause}");
    // Error reporting
    ErrorReporting.report(error);
    
    // Show user-friendly error
    showErrorSnackBar(error.cause);
  },
  
  onTypingOn: () {
    print("User is typing...");
    // Show typing indicator
  },
  
  onTypingOff: () {
    print("User stopped typing");
    // Hide typing indicator
  },
);
```

## 📱 Platform Support

### Android

- **Minimum SDK**: 21 (Android 5.0)
- **Target SDK**: 34 (Android 14)
- **Features**: Full feature support including file attachments, push notifications
- **Permissions**: Camera, storage access (handled automatically)

### iOS

- **Minimum Version**: iOS 12.0
- **Features**: Full feature support including file attachments, push notifications
- **Permissions**: Camera, photo library access (handled automatically)

### Web

- **Support**: ✅ Full support with some limitations
- **Webview**: Uses iframe for DOOWidget (some features limited)
- **File Uploads**: Supported via HTML file input
- **Real-time**: WebSocket support available

### Platform-Specific Considerations

```dart
import 'package:flutter/foundation.dart';

Widget buildChatWidget() {
  if (kIsWeb) {
    // Web-optimized implementation
    return DOOChatPage(
      websiteToken: "your_token",
      baseUrl: "https://your-instance.com",
      enableAttachments: true, // Works on web via file input
    );
  } else {
    // Mobile implementation with full features
    return DOOWidget(
      websiteToken: "your_token", 
      baseUrl: "https://your-instance.com",
      onAttachFile: () async {
        // Native file picker
        return await FilePicker.platform.pickFiles();
      },
    );
  }
}
```

## 🔧 Advanced Configuration

### Environment Configuration

```dart
class DOOConfig {
  static const String prodBaseUrl = "https://app.doo.ooo";
  static const String stagingBaseUrl = "https://staging.doo.ooo";
  static const String devBaseUrl = "http://localhost:3000";
  
  static String get baseUrl {
    if (kDebugMode) return devBaseUrl;
    if (kProfileMode) return stagingBaseUrl;
    return prodBaseUrl;
  }
  
  static String get websiteToken {
    if (kDebugMode) return "dev_token_123";
    if (kProfileMode) return "staging_token_456";
    return "prod_token_789";
  }
}
```

### Custom User Attributes

```dart
DOOUser createUser(User appUser) {
  return DOOUser(
    identifier: appUser.id,
    name: appUser.displayName,
    email: appUser.email,
    avatarUrl: appUser.photoURL,
    customAttributes: {
      // User segmentation
      "user_type": appUser.isPremium ? "premium" : "free",
      "signup_date": appUser.createdAt.toIso8601String(),
      "last_seen": DateTime.now().toIso8601String(),
      
      // App context
      "app_version": "1.0.0",
      "platform": Platform.operatingSystem,
      "device_type": Platform.isIOS ? "ios" : "android",
      
      // Business data
      "total_orders": appUser.orderCount,
      "lifetime_value": appUser.lifetimeValue,
      "subscription_status": appUser.subscriptionStatus,
    },
  );
}
```

### Performance Optimization

```dart
class OptimizedChatScreen extends StatefulWidget {
  @override
  _OptimizedChatScreenState createState() => _OptimizedChatScreenState();
}

class _OptimizedChatScreenState extends State<OptimizedChatScreen> 
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true; // Preserve state
  
  late DOOClient _client;
  
  @override
  void initState() {
    super.initState();
    _initClient();
  }
  
  Future<void> _initClient() async {
    _client = await DOOClient.create(
      baseUrl: DOOConfig.baseUrl,
      inboxIdentifier: DOOConfig.websiteToken,
      user: UserService.currentDOOUser,
      callbacks: _createOptimizedCallbacks(),
      // Performance settings
      enablePersistence: true, // Cache messages locally
      messageLimit: 50, // Limit loaded messages
      autoReconnect: true, // Handle connection drops
    );
  }
  
  DOOCallbacks _createOptimizedCallbacks() {
    return DOOCallbacks(
      onMessageReceived: (message) {
        // Batch UI updates to avoid excessive rebuilds
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() => _messages.add(message));
          });
        }
      },
      onError: (error) {
        // Graceful error handling
        if (error.type == DOOErrorType.networkError) {
          _showRetrySnackBar();
        }
      },
    );
  }
  
  @override
  void dispose() {
    _client.dispose(); // Clean up resources
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return /* your widget tree */;
  }
}
```

## 📖 API Reference

### Core Classes

#### DOOClient

The main client for programmatic chat interaction.

```dart
class DOOClient {
  /// Creates a new DOO client instance
  static Future<DOOClient> create({
    required String baseUrl,
    required String inboxIdentifier, 
    required DOOUser user,
    DOOCallbacks? callbacks,
    bool enablePersistence = true,
    int messageLimit = 100,
    bool autoReconnect = true,
  });
  
  /// Load conversation messages
  Future<void> loadMessages();
  
  /// Send a text message
  Future<String> sendMessage({required String content});
  
  /// Send a message with attachments
  Future<String> sendAttachment(String filePath);
  
  /// Dispose client and free resources
  void dispose();
}
```

#### DOOUser

User information for chat sessions.

```dart
class DOOUser {
  final String identifier;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final Map<String, dynamic>? customAttributes;
  
  DOOUser({
    required this.identifier,
    this.name,
    this.email, 
    this.avatarUrl,
    this.customAttributes,
  });
}
```

#### DOOMessage

Represents a chat message.

```dart
class DOOMessage {
  final int id;
  final String? content;
  final int messageType; // 0: outgoing, 1: incoming
  final String contentType; // "text", "image", "file"
  final Map<String, dynamic> contentAttributes;
  final String createdAt;
  final int conversationId;
  final List<DOOAttachment> attachments;
  final DOOMessageSender? sender;
  
  /// Whether this message was sent by the current user
  bool get isMine;
}
```

#### DOOCallbacks

Event handlers for chat interactions.

```dart
class DOOCallbacks {
  final VoidCallback? onWelcome;
  final Function(DOOMessage)? onMessageReceived;
  final Function(DOOMessage, String)? onMessageSent;
  final Function(List<DOOMessage>)? onMessagesRetrieved;
  final Function(List<DOOMessage>)? onPersistedMessagesRetrieved;
  final Function(DOOError)? onError;
  final VoidCallback? onTypingOn;
  final VoidCallback? onTypingOff;
}
```

### UI Components

#### DOOWidget

Webview-based chat widget.

```dart
DOOWidget({
  required String websiteToken,
  required String baseUrl,
  DOOUser? user,
  Map<String, dynamic>? customAttributes,
  Future<List<String>> Function()? onAttachFile,
  VoidCallback? onLoadStarted,
  Function(int)? onLoadProgress,
  VoidCallback? onLoadCompleted,
})
```

#### DOOChatDialog

Modal dialog for chat overlay.

```dart
DOOChatDialog({
  required String websiteToken,
  required String baseUrl,
  DOOUser? user,
  DOOChatTheme? theme,
  DOOLocalizations? l10n,
  bool enableAttachments = true,
})
```

#### DOOChatPage

Full-page chat interface.

```dart
DOOChatPage({
  required String websiteToken,
  required String baseUrl,
  DOOUser? user,
  PreferredSizeWidget? appBar,
  DOOChatTheme? theme,
  DOOLocalizations? l10n,
  bool enableAttachments = true,
  bool showUserNames = true,
  bool showUserAvatars = true,
})
```

## 💡 Best Practices

### 1. Error Handling

```dart
DOOCallbacks(
  onError: (error) {
    switch (error.type) {
      case DOOErrorType.networkError:
        // Show offline message, attempt reconnection
        showRetryDialog();
        break;
      case DOOErrorType.authenticationError:
        // Re-authenticate user
        reauthenticateUser();
        break;
      case DOOErrorType.validationError:
        // Show user-friendly validation message
        showValidationError(error.message);
        break;
      default:
        // Log error and show generic message
        logError(error);
        showGenericError();
    }
  },
)
```

### 2. Resource Management

```dart
class ChatManager {
  DOOClient? _client;
  
  Future<void> initializeChat() async {
    // Only create one client instance
    _client ??= await DOOClient.create(/* config */);
  }
  
  void dispose() {
    _client?.dispose();
    _client = null;
  }
}
```

### 3. State Management

```dart
// Using Provider/Riverpod for state management
class ChatState extends ChangeNotifier {
  List<DOOMessage> _messages = [];
  bool _isConnected = false;
  
  List<DOOMessage> get messages => _messages;
  bool get isConnected => _isConnected;
  
  void addMessage(DOOMessage message) {
    _messages.add(message);
    notifyListeners();
  }
  
  void setConnectionStatus(bool connected) {
    _isConnected = connected;
    notifyListeners();
  }
}
```

### 4. Security Considerations

```dart
DOOUser createSecureUser(User user) {
  return DOOUser(
    identifier: hashUserId(user.id), // Don't expose internal IDs
    name: sanitizeInput(user.name),
    email: user.isEmailVerified ? user.email : null,
    customAttributes: {
      // Only include necessary, non-sensitive data
      "user_segment": user.segment,
      "app_version": AppConfig.version,
      // Don't include: passwords, internal IDs, sensitive data
    },
  );
}
```

## 🐛 Troubleshooting

### Common Issues and Solutions

#### 1. Connection Problems

**Issue**: "Failed to connect to DOO instance"

**Solutions**:
```dart
// Check network connectivity
Future<bool> hasNetworkConnection() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}

// Validate configuration
void validateConfig() {
  assert(baseUrl.isNotEmpty, "Base URL cannot be empty");
  assert(websiteToken.isNotEmpty, "Website token cannot be empty");
  assert(Uri.tryParse(baseUrl) != null, "Invalid base URL format");
}
```

#### 2. Messages Not Loading

**Issue**: Messages don't appear or load slowly

**Solutions**:
```dart
// Ensure proper initialization order
Future<void> initializeChat() async {
  final client = await DOOClient.create(/* config */);
  
  // Wait for connection before loading messages
  await client.connect();
  await client.loadMessages();
}

// Check callback implementation
DOOCallbacks(
  onMessagesRetrieved: (messages) {
    // Ensure UI updates on main thread
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    });
  },
)
```

#### 3. File Attachments Not Working

**Issue**: File uploads fail or don't show

**Solutions**:
```dart
// Add required permissions (Android)
// android/app/src/main/AndroidManifest.xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />

// iOS permissions (ios/Runner/Info.plist)
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera to take photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library to select images</string>

// Implement proper file handling
Future<List<String>> handleFileAttachment() async {
  try {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    return image != null ? [image.path] : [];
  } catch (e) {
    print("File attachment error: $e");
    return [];
  }
}
```

#### 4. Web Platform Issues

**Issue**: Widget doesn't work properly on web

**Solutions**:
```dart
// Use web-compatible implementations
Widget buildChatForPlatform() {
  if (kIsWeb) {
    return DOOChatPage( // Better web support
      websiteToken: token,
      baseUrl: baseUrl,
      enableAttachments: true, // Uses HTML file input
    );
  } else {
    return DOOWidget( // Full native support
      websiteToken: token,
      baseUrl: baseUrl,
      onAttachFile: () async => await nativeFilePicker(),
    );
  }
}
```

### Debug Mode

Enable debug logging for troubleshooting:

```dart
// Enable debug mode during development
void main() {
  if (kDebugMode) {
    DOOClient.enableDebugLogging(true);
  }
  runApp(MyApp());
}
```

### Getting Help

1. **Documentation**: Check the [API reference](https://pub.dev/documentation/doo_cx_flutter_sdk_plus/latest/)
2. **GitHub Issues**: [Report bugs or request features](https://github.com/doo-inc/doo-cx-flutter-sdk/issues)
3. **Support**: Contact support@doo.ooo for technical assistance
4. **Community**: Join our Discord server for community support

## 📚 Examples

### Complete App Example

```dart
import 'package:flutter/material.dart';
import 'package:doo_cx_flutter_sdk_plus/doo_cx_flutter_sdk_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DOO CX Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatScreen()),
              ),
              child: Text('Open Chat'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showChatDialog(context),
              child: Text('Show Chat Dialog'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showChatDialog(context),
        child: Icon(Icons.chat),
      ),
    );
  }

  void _showChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => DOOChatDialog(
        websiteToken: "YOUR_WEBSITE_TOKEN",
        baseUrl: "https://your-instance.doo.ooo",
        user: DOOUser(
          identifier: "user_123",
          name: "John Doe",
          email: "john@example.com",
        ),
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DOOChatPage(
        websiteToken: "YOUR_WEBSITE_TOKEN",
        baseUrl: "https://your-instance.doo.ooo",
        user: DOOUser(
          identifier: "user_123",
          name: "John Doe",
          email: "john@example.com",
        ),
        appBar: AppBar(
          title: Text('Customer Support'),
          backgroundColor: Colors.blue,
        ),
        theme: DOOChatTheme(
          primaryColor: Colors.blue,
          userMessageBackgroundColor: Colors.blue,
          botMessageBackgroundColor: Colors.grey[100],
        ),
      ),
    );
  }
}
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- **Website**: [doo.ooo](https://www.doo.ooo)
- **Documentation**: [API Reference](https://pub.dev/documentation/doo_cx_flutter_sdk_plus/latest/)
- **GitHub**: [Source Code](https://github.com/doo-inc/doo-cx-flutter-sdk)
- **Pub.dev**: [Package](https://pub.dev/packages/doo_cx_flutter_sdk_plus)
- **Support**: support@doo.ooo

---

Made with ❤️ by the DOO CX team