import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:doo_cx_flutter_sdk/doo_cx_flutter_sdk.dart';
import 'package:doo_cx_flutter_sdk/data/local/entity/doo_user.dart';
import 'package:doo_cx_flutter_sdk/ui/doo_chat_theme.dart';
import 'package:doo_cx_flutter_sdk/ui/doo_l10n.dart';

// For the custom DOOClient chat with "attachment" (image) sending
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

// ========= EDIT THESE =========
const String baseUrl = "BASE-URL";
const String inboxIdentifier =
    "SDK-TOKEN"; //SDK Token you get from setting up yout inbox channel
const String agentDisplayName = "AGENT-DISPLAY-NAME";
// ==============================

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DOO Sandbox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const MinimalChatLauncher(),
    );
  }
}

class MinimalChatLauncher extends StatelessWidget {
  const MinimalChatLauncher({super.key});

  void _openDOOChatDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => MyChatDialog(
        baseUrl: baseUrl,
        inboxIdentifier: inboxIdentifier,
        agentTitle: agentDisplayName,
        user: DOOUser(
          identifier: "flutter_tester",
          name: "Flutter Tester",
          email: "someone@example.com",
        ),
      ),
    );
  }

  void _openDOOClientDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => MyDOOClientDialog(
        baseUrl: baseUrl,
        inboxIdentifier: inboxIdentifier,
        agentTitle: "$agentDisplayName (Client UI)",
        user: DOOUser(
          identifier: "flutter_tester",
          name: "Flutter Tester",
          email: "someone@example.com",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = 16 + MediaQuery.of(context).padding.bottom;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 16,
            bottom: bottom,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    elevation: 3,
                  ),
                  onPressed: () => _openDOOChatDialog(context),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat'),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    elevation: 3,
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _openDOOClientDialog(context),
                  icon: const Icon(Icons.integration_instructions),
                  label: const Text('Client Chat'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

///DOOChat dialog (your original)

class MyChatDialog extends StatefulWidget {
  final String baseUrl;
  final String inboxIdentifier;
  final String agentTitle;
  final DOOUser? user;

  const MyChatDialog({
    super.key,
    required this.baseUrl,
    required this.inboxIdentifier,
    required this.agentTitle,
    this.user,
  });

  @override
  State<MyChatDialog> createState() => _MyChatDialogState();
}

enum _Presence { offline, online, typing }

class _MyChatDialogState extends State<MyChatDialog> {
  final DOOL10n l10n = const DOOL10n(
    onlineText: 'Online',
    offlineText: 'Offline',
    typingText: 'Typing…',
  );

  _Presence presence = _Presence.offline;
  bool _isOnline = false;
  bool _isTyping = false;
  Timer? _typingTimer;
  static const Duration _typingHold = Duration(seconds: 4);

  String get _statusText {
    switch (presence) {
      case _Presence.typing:
        return l10n.typingText;
      case _Presence.online:
        return l10n.onlineText;
      case _Presence.offline:
      default:
        return l10n.offlineText;
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  void _applyPresence() {
    setState(() {
      if (_isOnline) {
        presence = _isTyping ? _Presence.typing : _Presence.online;
      } else {
        presence = _Presence.offline;
      }
    });
  }

  void _startTypingWindow() {
    _typingTimer?.cancel();
    _typingTimer = Timer(_typingHold, () {
      _isTyping = false;
      _applyPresence();
    });
  }

  void _onOnline() {
    _isOnline = true;
    _applyPresence();
  }

  void _onOffline() {
    _isOnline = false;
    _isTyping = false;
    _typingTimer?.cancel();
    _applyPresence();
  }

  void _onStartedTyping() {
    _isTyping = true;
    _isOnline = true;
    _applyPresence();
    _startTypingWindow();
  }

  void _onStoppedTyping() {
    _isTyping = false;
    _typingTimer?.cancel();
    _applyPresence();
  }

  void _onMessageReceived(DOOMessage m) {
    _onStoppedTyping();
    _onOnline();
  }

  @override
  Widget build(BuildContext context) {
    final showGreenDot = presence != _Presence.offline;

    return Dialog(
      insetPadding: const EdgeInsets.all(8),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(widget.agentTitle,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          if (showGreenDot)
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                        ]),
                        const SizedBox(height: 2),
                        Text(_statusText, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const Divider(height: 1),
            Expanded(
              child: DOOChat(
                baseUrl: widget.baseUrl,
                inboxIdentifier: widget.inboxIdentifier,
                user: widget.user,
                enablePersistence: true,
                theme: DOOChatTheme(
                  primaryColor: DOO_COLOR_PRIMARY,
                  secondaryColor: Colors.white,
                  backgroundColor: DOO_BG_COLOR,
                  userAvatarNameColors: [DOO_COLOR_PRIMARY],
                ),
                isPresentedInDialog: true,
                onConversationIsOnline: _onOnline,
                onConversationIsOffline: _onOffline,
                onConversationStartedTyping: _onStartedTyping,
                onConversationStoppedTyping: _onStoppedTyping,
                onMessageReceived: _onMessageReceived,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =============== Custom DOOClient dialog with "attachments" =================
/// NOTE: There is no native file-upload in DOOClient right now. This UI
/// picks an image, writes it to a temp file, and sends a message containing
/// the file URI (so you can parse/handle it on the server or later enhance
/// the SDK to treat it as an attachment).

class MyDOOClientDialog extends StatefulWidget {
  final String baseUrl;
  final String inboxIdentifier;
  final String agentTitle;
  final DOOUser? user;

  const MyDOOClientDialog({
    super.key,
    required this.baseUrl,
    required this.inboxIdentifier,
    required this.agentTitle,
    this.user,
  });

  @override
  State<MyDOOClientDialog> createState() => _MyDOOClientDialogState();
}

class _MyDOOClientDialogState extends State<MyDOOClientDialog> {
  DOOClient? _client;
  final TextEditingController _text = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<DOOMessage> _messages = [];
  bool _loading = true;
  String _status = "Connecting…";

  @override
  void initState() {
    super.initState();
    _initClient();
  }

  Future<void> _initClient() async {
    final callbacks = DOOCallbacks(
      onWelcome: () => setState(() => _status = "Connected"),
      onPersistedMessagesRetrieved: (persisted) {
        setState(() {
          _messages
            ..clear()
            ..addAll(persisted);
        });
      },
      onMessagesRetrieved: (msgs) {
        setState(() {
          _messages
            ..clear()
            ..addAll(msgs);
          _loading = false;
        });
      },
      onMessageReceived: (m) {
        setState(() => _messages.add(m));
        _jumpToBottom();
      },
      onMessageSent: (m, echoId) {
        // Replace optimistic (negative id) if necessary
        setState(() {
          _messages.removeWhere((x) => x.content == m.content && x.id < 0);
          if (!_messages.any((x) => x.id == m.id)) {
            _messages.add(m);
          }
        });
        _jumpToBottom();
      },
      onError: (e) => setState(() {
        _status = "Error: ${e.cause}";
        _loading = false;
      }),
    );

    try {
      _client = await DOOClient.create(
        baseUrl: widget.baseUrl,
        inboxIdentifier: widget.inboxIdentifier,
        user: widget.user,
        callbacks: callbacks,
      );
      await _client!.loadMessages();
    } catch (e) {
      setState(() {
        _status = "Failed to initialize: $e";
        _loading = false;
      });
    }
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendText() async {
    final content = _text.text.trim();
    if (content.isEmpty || _client == null) return;

    _text.clear();

    // Optimistic message
    final optimistic = DOOMessage(
      id: -DateTime.now().millisecondsSinceEpoch,
      content: content,
      messageType: 0, // outgoing
      contentType: "text",
      contentAttributes: {},
      createdAt: DateTime.now().toIso8601String(),
      conversationId: 0,
      attachments: const [],
      sender: null,
    );
    setState(() => _messages.add(optimistic));
    _jumpToBottom();

    try {
      await _client!.sendMessage(content: content);
    } catch (_) {
      // Remove optimistic on failure
      setState(() {
        _messages.removeWhere((m) => m.id == optimistic.id);
      });
    }
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x == null) return;

    try {
      final raw = await x.readAsBytes();
      final decoded = img.decodeImage(raw);
      if (decoded == null) return;

      // Resize to keep message size reasonable
      final scaled = img.copyResize(decoded, width: 1000);
      final jpg = img.encodeJpg(scaled, quality: 90);

      final dir = await getTemporaryDirectory();
      final file =
          File('${dir.path}/doo_${DateTime.now().microsecondsSinceEpoch}.jpg');
      await file.writeAsBytes(jpg, flush: true);

      final uri = file.uri.toString();

      // Send as a text message containing the local URI
      // (Server/SDK doesn’t accept binary via DOOClient yet.)
      final content = "Attachment: $uri";

      final optimistic = DOOMessage(
        id: -DateTime.now().millisecondsSinceEpoch,
        content: content,
        messageType: 0,
        contentType: "text",
        contentAttributes: {"attachmentUri": uri},
        createdAt: DateTime.now().toIso8601String(),
        conversationId: 0,
        attachments: const [],
        sender: null,
      );
      setState(() => _messages.add(optimistic));
      _jumpToBottom();

      await _client!.sendMessage(content: content);
    } catch (e) {
      // You can show a toast/snackbar here if you want
    }
  }

  @override
  void dispose() {
    _client?.dispose();
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(8),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: 520,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.agentTitle,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(_status, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? const Center(child: Text('No messages yet'))
                      : ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.all(8),
                          itemCount: _messages.length,
                          itemBuilder: (context, i) {
                            final m = _messages[i];
                            final isMine = m.isMine;
                            return Align(
                              alignment: isMine
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isMine
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  m.content ?? '',
                                  style: TextStyle(
                                    color: isMine ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Attach image',
                      icon: const Icon(Icons.attach_file),
                      onPressed: _pickAndSendImage,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _text,
                        decoration: const InputDecoration(
                          hintText: 'Type a message…',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        onSubmitted: (_) => _sendText(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Send',
                      icon: const Icon(Icons.send),
                      onPressed: _sendText,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
