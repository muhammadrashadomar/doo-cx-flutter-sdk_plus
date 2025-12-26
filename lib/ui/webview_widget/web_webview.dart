import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:doo_cx_flutter_sdk_plus/ui/webview_widget/utils.dart';

/// Web-specific implementation of DOO webview using HTML iframe
///
/// This implementation uses HTML iframe for web platform compatibility
/// since webview_flutter doesn't fully support web.
///
/// {@category FlutterClientSdk}
class WebWebview extends StatefulWidget {
  /// Website channel token for authentication
  final String websiteToken;

  /// Base URL of your DOO installation
  final String baseUrl;

  /// Callback triggered when the widget is closed
  final void Function()? closeWidget;

  /// Callback to handle file attachment selection
  final Future<List<String>> Function()? onAttachFile;

  /// Callback triggered when the widget starts loading
  final void Function()? onLoadStarted;

  /// Callback triggered during widget loading with progress percentage
  final void Function(int)? onLoadProgress;

  /// Callback triggered when the widget finishes loading
  final void Function()? onLoadCompleted;

  /// Creates a WebWebview instance with the specified configuration
  const WebWebview(
      {Key? key,
      required this.websiteToken,
      required this.baseUrl,
      this.closeWidget,
      this.onAttachFile,
      this.onLoadStarted,
      this.onLoadProgress,
      this.onLoadCompleted})
      : super(key: key);

  @override
  _WebWebviewState createState() => _WebWebviewState();
}

class _WebWebviewState extends State<WebWebview> {
  late html.IFrameElement _iframe;
  bool _isLoading = true;
  String _viewId = '';

  @override
  void initState() {
    super.initState();
    _viewId = 'doo-widget-${DateTime.now().millisecondsSinceEpoch}';

    // Register the view factory immediately
    _registerViewFactory();

    _initWebView();
  }

  void _registerViewFactory() {
    // Create a simple div as placeholder until iframe is ready
    final html.DivElement placeholder = html.DivElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.display = 'flex'
      ..style.alignItems = 'center'
      ..style.justifyContent = 'center'
      ..text = 'Loading...';

    // Register the placeholder first
    ui.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) => placeholder,
    );
  }

  Future<void> _initWebView() async {
    // Build widget URL
    String webviewUrl =
        "${widget.baseUrl}/widget?website_token=${widget.websiteToken}&locale=en";

    // Get the stored conversation cookie if available
    final dooConversationCookie = await StoreHelper.getCookie();
    if (dooConversationCookie.isNotEmpty) {
      webviewUrl = "$webviewUrl&doo_conversation=$dooConversationCookie";
    }

    // Create iframe element
    _iframe = html.IFrameElement()
      ..src = webviewUrl
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allowFullscreen = true;

    // Set up message listener for communication with iframe
    html.window.onMessage.listen(_handleMessage);

    // Update the registered view factory with the actual iframe
    ui.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) => _iframe,
    );

    // Simulate loading progress
    widget.onLoadStarted?.call();
    widget.onLoadProgress?.call(50);

    // Set up iframe load event
    _iframe.onLoad.listen((_) {
      setState(() => _isLoading = false);
      widget.onLoadCompleted?.call();
      widget.onLoadProgress?.call(100);

      // Inject JavaScript after iframe loads
      _injectJavaScript();
    });
  }

  void _injectJavaScript() {
    try {
      // Generate default JavaScript for basic functionality
      final injectedJavaScript = generateScripts(
        user: null, // Will be set via DOOWidget parameters
        locale: "en",
        customAttributes: null,
      );

      // Try to inject JavaScript into iframe (may be restricted by CORS)
      if (injectedJavaScript.isNotEmpty) {
        final script = '''
          try {
            ${injectedJavaScript}
          } catch (e) {
            console.log('DOO SDK: Script injection error:', e);
          }
        ''';

        // Send script to iframe via postMessage
        _iframe.contentWindow
            ?.postMessage({'type': 'script', 'script': script}, '*');
      }
    } catch (e) {
      if (kDebugMode) {
        print('DOO SDK: Error injecting JavaScript: $e');
      }
    }
  }

  void _handleMessage(html.MessageEvent event) {
    try {
      final data = event.data;
      if (data is Map) {
        final type = data['type'];

        // Handle close widget events
        if (type == 'close-widget' || type == 'close') {
          Future.microtask(() {
            widget.closeWidget?.call();
          });
        }

        // Handle DOO specific events
        if (data.containsKey('event')) {
          final eventType = data['event'];

          if (eventType == 'loaded') {
            final authToken = data['config']?['authToken'];
            if (authToken != null) {
              StoreHelper.storeCookie(authToken);
              _injectJavaScript();
            }
          }
        }
      } else if (data is String) {
        // Handle string messages
        final message = getMessage(data);
        if (isJsonString(message)) {
          final parsedMessage = jsonDecode(message);
          final eventType = parsedMessage["event"];
          final type = parsedMessage["type"];

          if (eventType == 'loaded') {
            final authToken = parsedMessage["config"]?["authToken"];
            if (authToken != null) {
              StoreHelper.storeCookie(authToken);
              _injectJavaScript();
            }
          }

          if (type == 'close-widget' ||
              type == 'close' ||
              eventType == 'close-widget') {
            Future.microtask(() {
              widget.closeWidget?.call();
            });
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('DOO SDK: Error handling message: $e');
      }
    }
  }

  @override
  void dispose() {
    // Note: onMessage.listen creates a subscription that's automatically disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        HtmlElementView(viewType: _viewId),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
