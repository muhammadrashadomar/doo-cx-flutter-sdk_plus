# DOO CX Flutter SDK

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
- ⚡ **Performance Optimized** - Efficient memory usage and fast rendering

## 🚀 Quick Start

```bash
# 1. Add to your project
flutter pub add doo_cx_flutter_sdk_plus

# 2. Import and use
import 'package:doo_cx_flutter_sdk_plus/doo_cx_flutter_sdk_plus.dart';

# 3. Add a simple widget
DOOWidget(
  websiteToken: "your_website_token",
  baseUrl: "https://your-doo-instance.com",
)
```

## Table of Contents

- [Installation](#1-installation)
- [Integration Methods](#2-integration-methods)
  - [Using DOOWidget](#a-using-doowidget)
  - [Using DOO Chat Dialog](#b-using-doo-chat-dialog)
  - [Using DOO Chat Page](#c-using-doo-chat-page)
  - [Using DOOClient directly](#d-using-dooclient-directly)
- [Customization](#3-customization)
- [Handling File Attachments](#4-handling-file-attachments)
- [Advanced Configuration](#5-advanced-configuration)
- [Example App](#6-example-app)
- [Troubleshooting](#7-troubleshooting)

## 1. Installation

### Add the package to your project

Run the command below in your terminal:

```bash
flutter pub add doo_cx_flutter_sdk_plus
```

Or add it manually to your project's `pubspec.yaml` file:

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

## 2. Integration Methods

There are multiple ways to integrate DOO CX into your Flutter application, depending on your needs:

### a. Using DOOWidget

DOOWidget provides a ready-to-use webview that displays the DOO chat interface. This is the simplest way to integrate DOO CX into your app.

#### Steps:

1. Create a website channel in DOO dashboard
2. Get your website token from the DOO dashboard
3. Add the widget to your app:

```dart
import 'package:doo_cx_flutter_sdk_plus/doo_cx_flutter_sdk_plus.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DOO CX Demo'),
      ),
      body: DOOWidget(
        websiteToken: "your_website_token",
        baseUrl: "https://cx.doo.ooo",
        user: DOOUser(
          identifier: "user_123",
          name: "John Doe",
          email: "john@example.com",
        ),
        locale: "en",
        closeWidget: () {
          Navigator.pop(context);
        },
        onAttachFile: _handleAttachFile,
        onLoadStarted: () {
          print("Loading Widget");
        },
        onLoadProgress: (int progress) {
          print("Loading... $progress");
        },
        onLoadCompleted: () {
          print("Widget Loaded");
        },
      ),
    );
  }

  Future<List<String>> _handleAttachFile() async {
    // Implement file attachment selection logic
    // Return a list of file URIs
    return [];
  }
}
```

#### Available Parameters

| Name             | Default | Type                            | Description                                                                                            |
|------------------|---------|---------------------------------|--------------------------------------------------------------------------------------------------------|
| websiteToken     | -       | String                          | Website inbox channel token (required)                                                                 |
| baseUrl          | -       | String                          | Installation URL for DOO CX (required)                                                                 |
| user             | -       | DOOUser                         | User information including identifier, name, email, and avatar URL                                     |
| locale           | en      | String                          | User locale for localization                                                                           |
| closeWidget      | -       | void Function()                 | Callback triggered when the widget is closed                                                           |
| customAttributes | -       | dynamic                         | Additional information about the customer                                                              |
| onAttachFile     | -       | Future<List<String>> Function() | Callback to handle file attachment selection                                                           |
| onLoadStarted    | -       | void Function()                 | Callback triggered when the widget starts loading                                                      |
| onLoadProgress   | -       | void Function(int)              | Callback triggered during widget loading with progress percentage                                      |
| onLoadCompleted  | -       | void Function()                 | Callback triggered when the widget finishes loading                                                    |

### b. Using DOO Chat Dialog

DOO Chat Dialog provides a modal dialog with a built-in chat interface. This is useful when you want to show the chat as an overlay.

```dart
import 'package:doo_cx_flutter_sdk_plus/doo_cx_flutter_sdk_plus.dart';
import 'package:flutter/material.dart';

void showDOOChatDialog(BuildContext context) {
  DOOChatDialog.show(
    context,
    baseUrl: "https://cx.doo.ooo",
    inboxIdentifier: "your_inbox_identifier",
    title: "DOO Support",
    user: DOOUser(
      identifier: "user_123",
      name: "John Doe",
      email: "john@example.com",
    ),
  );
}
```

### c. Using DOO Chat Page

DOO Chat Page provides a full-screen chat interface. This is useful when you want to navigate to a dedicated chat screen.

```dart
import 'package:doo_cx_flutter_sdk_plus/doo_cx_flutter_sdk_plus.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DOOChatPage(
      baseUrl: "https://cx.doo.ooo",
      inboxIdentifier: "your_inbox_identifier",
      user: DOOUser(
        identifier: "user_123",
        name: "John Doe",
        email: "john@example.com",
      ),
      appBar: AppBar(
        title: Text("DOO Support"),
      ),
    );
  }
}
```

### d. Using DOOClient directly

For more advanced use cases, you can use the DOOClient directly to integrate with your custom UI.

```dart
import 'package:doo_cx_flutter_sdk_plus/doo_cx_flutter_sdk_plus.dart';
import 'package:flutter/material.dart';

class CustomChatPage extends StatefulWidget {
  @override
  _CustomChatPageState createState() => _CustomChatPageState();
}

class _CustomChatPageState extends State<CustomChatPage> {
  DOOClient? _client;
  List<DOOMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDOOClient();
  }

  Future<void> _initDOOClient() async {
    final dooCallbacks = DOOCallbacks(
      onWelcome: () {
        print("Welcome");
      },
      onMessagesRetrieved: (messages) {
        setState(() {
          _messages = messages;
        });
      },
      onMessageReceived: (message) {
        setState(() {
          _messages.add(message);
        });
      },
      onMessageSent: (message, echoId) {
        print("Message sent: $echoId");
      },
      onError: (error) {
        print("Error: ${error.cause}");
      },
    );

    try {
      _client = await DOOClient.create(
        baseUrl: "https://cx.doo.ooo",
        inboxIdentifier: "your_inbox_identifier",
        user: DOOUser(
          identifier: "user_123",
          name: "John Doe",
          email: "john@example.com",
        ),
        callbacks: dooCallbacks,
      );
      
      _client!.loadMessages();
    } catch (e) {
      print("Failed to initialize DOO client: $e");
    }
  }

  Future<void> _sendMessage() async {
    if (_textController.text.isNotEmpty && _client != null) {
      final content = _textController.text;
      _textController.clear();
      
      try {
        final echoId = await _client!.sendMessage(content: content);
        print("Message sent with echo ID: $echoId");
      } catch (e) {
        print("Failed to send message: $e");
      }
    }
  }

  @override
  void dispose() {
    _client?.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Implement your custom chat UI here
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text(message.content ?? ''),
                  subtitle: Text(message.sender?.name ?? 'Unknown'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

#### Available Parameters for DOOClient

| Name              | Default | Type           | Description                                                                                                                                                                                                                         |
|-------------------|---------|----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| baseUrl           | -       | String         | Installation URL for DOO CX (required)                                                                                                                                                                                              |
| inboxIdentifier   | -       | String         | Identifier for target DOO inbox (required)                                                                                                                                                                                          |
| enablePersistence | true    | bool           | Enables persistence of conversation data                                                                                                                                                                                             |
| websiteToken      | null    | String         | Website token for widget authentication (used in webview integration)                                                                                                                                                                |
| locale            | en      | String         | User locale for localization                                                                                                                                                                                                         |
| user              | null    | DOOUser        | Custom user details to be attached to DOO contact                                                                                                                                                                                   |
| callbacks         | null    | DOOCallbacks   | Callbacks for handling DOO events                                                                                                                                                                                                   |

## 3. Customization

You can customize the appearance of the DOO chat interface using the following options:

### Theme Customization

When using DOOChatPage or DOOChatDialog, you can customize the theme by providing a DOOChatTheme:

```dart
DOOChatPage(
  baseUrl: "https://cx.doo.ooo",
  inboxIdentifier: "your_inbox_identifier",
  theme: DOOChatTheme(
    primaryColor: Colors.blue,
    secondaryColor: Colors.white,
    backgroundColor: Colors.grey[100],
    // Additional theme properties...
  ),
  // Other parameters...
)
```

### Localization

You can customize the text strings used in the chat interface by providing a DOOLocalizations object:

```dart
DOOChatPage(
  baseUrl: "https://cx.doo.ooo",
  inboxIdentifier: "your_inbox_identifier",
  locale: "fr", // Set the language
  l10n: DOOLocalizations(
    inputPlaceholder: "Écrivez un message...",
    sendButtonAccessibilityLabel: "Envoyer",
    // Additional localization properties...
  ),
  // Other parameters...
)
```

## 4. Handling File Attachments

To enable file attachments in DOOWidget, implement the `onAttachFile` callback:

```dart
import 'dart:io';
import 'package:doo_cx_flutter_sdk_plus/doo_cx_flutter_sdk_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

Future<List<String>> handleAttachFile() async {
  final picker = ImagePicker();
  final photo = await picker.pickImage(source: ImageSource.gallery);

  if (photo == null) {
    return [];
  }

  final imageData = await photo.readAsBytes();
  final decodedImage = img.decodeImage(imageData);
  if (decodedImage == null) {
    return [];
  }
  
  final scaledImage = img.copyResize(decodedImage, width: 500);
  final jpg = img.encodeJpg(scaledImage, quality: 90);

  final filePath = (await getTemporaryDirectory()).uri.resolve(
    './image_${DateTime.now().microsecondsSinceEpoch}.jpg',
  );
  final file = await File.fromUri(filePath).create(recursive: true);
  await file.writeAsBytes(jpg, flush: true);

  return [file.uri.toString()];
}
```

## 5. Advanced Configuration

### Handling Authentication

If you need to authenticate users with your backend before connecting to DOO CX:

```dart
// First authenticate with your backend
final authToken = await yourAuthService.authenticate(username, password);

// Then use the authentication token in the DOO user
final dooUser = DOOUser(
  identifier: userId,
  name: userName,
  email: userEmail,
  customAttributes: {
    'auth_token': authToken,
    'user_role': userRole,
    // Add any other attributes you want to pass to DOO
  }
);

// Create the DOO client with the authenticated user
final client = await DOOClient.create(
  baseUrl: "https://cx.doo.ooo",
  inboxIdentifier: "your_inbox_identifier",
  user: dooUser,
);
```

### Handling Multiple Inbox Configurations

If your app needs to connect to different DOO inboxes based on user segments:

```dart
String getInboxIdentifier(User user) {
  if (user.isPremium) {
    return "premium_support_inbox";
  } else if (user.language == "fr") {
    return "french_support_inbox";
  } else {
    return "general_support_inbox";
  }
}

// Then use the determined inbox identifier
final client = await DOOClient.create(
  baseUrl: "https://cx.doo.ooo",
  inboxIdentifier: getInboxIdentifier(currentUser),
  user: dooUser,
);
```

## 6. Example App

The SDK includes an example app that demonstrates how to integrate DOO CX into a Flutter application. You can find it in the `example` directory.

To run the example app:

1. Clone the repository
2. Navigate to the example directory: `cd example`
3. Update the configuration in `lib/main.dart` with your DOO CX credentials
4. Run the app: `flutter run`

## 7. Troubleshooting

### Common Issues

#### Unable to Connect to DOO CX

- Ensure you're using the correct baseUrl and inboxIdentifier/websiteToken
- Check your internet connection
- Verify that your DOO CX account is active

#### Messages Not Loading

- Ensure you've called `loadMessages()` after creating the DOOClient
- Check the onError callback for any error messages
- Verify that your inbox is properly configured in the DOO dashboard

#### File Attachments Not Working

- Make sure you've implemented the onAttachFile callback correctly
- Check that you have the proper permissions in your app (camera, photo library)
- Verify that the file format is supported

### Getting Help

If you encounter any issues with the DOO CX Flutter SDK, please contact our support team at support@doo.ooo or open an issue on our GitHub repository.

---

© 2025 DOO Inc. All rights reserved.
