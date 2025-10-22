import 'dart:convert';
import 'package:doo_cx_flutter_sdk/ui/webview_widget/utils.dart';
import 'package:doo_cx_flutter_sdk/ui/webview_widget/platform_webview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../data/local/entity/doo_user.dart';

/// DOO webview implementation
/// 
/// This is an internal implementation of the webview that powers the DOOWidget.
/// It handles initialization, JavaScript injection, cookies, and event handling.
/// 
/// {@category FlutterClientSdk}
class Webview extends StatefulWidget {
  /// URL for DOO widget in webview
  final String widgetUrl;

  /// DOO user & locale initialization script
  final String injectedJavaScript;

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

  /// Creates a Webview instance with the specified configuration
  Webview({
    Key? key,
    required String websiteToken,
    required String baseUrl,
    DOOUser? user,
    String locale = "en",
    dynamic customAttributes,
    this.closeWidget,
    this.onAttachFile,
    this.onLoadStarted,
    this.onLoadProgress,
    this.onLoadCompleted
  }) : 
    widgetUrl = "${baseUrl}/widget?website_token=${websiteToken}&locale=${locale}",
    injectedJavaScript = generateScripts(
      user: user, 
      locale: locale, 
      customAttributes: customAttributes
    ),
    super(key: key);

  @override
  _WebviewState createState() => _WebviewState();
}

class _WebviewState extends State<Webview> {
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Only initialize webview for non-web platforms
    if (!kIsWeb) {
      // Configure platform-specific implementations  
      if (defaultTargetPlatform == TargetPlatform.android) {
        WebViewPlatform.instance = AndroidWebViewPlatform();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        WebViewPlatform.instance = WebKitWebViewPlatform();
      }
      
      _initWebView();
    }
  }

  Future<void> _initWebView() async {
    // Get the stored conversation cookie if available
    String webviewUrl = widget.widgetUrl;
    final dooConversationCookie = await StoreHelper.getCookie();
    if (dooConversationCookie.isNotEmpty) {
      webviewUrl = "$webviewUrl&doo_conversation=$dooConversationCookie";
    }

    // Create and configure the WebViewController
    final controller = WebViewController();
    
    // Configure JavaScript and background color
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.setBackgroundColor(Colors.white);
    
    controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            widget.onLoadProgress?.call(progress);
          },
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            widget.onLoadStarted?.call();
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            widget.onLoadCompleted?.call();
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("WebView error: ${error.description}");
          },
          onNavigationRequest: (NavigationRequest request) {
            // Handle file selection
            if (request.url.startsWith('file://')) {
              _handleFileSelection();
              return NavigationDecision.prevent;
            }
            
            // Open external links in browser
            _goToUrl(request.url);
            return NavigationDecision.prevent;
          },
        ),
      )
      ..addJavaScriptChannel(
        "ReactNativeWebView",
        onMessageReceived: _handleJavaScriptMessage
      )
      ..loadRequest(Uri.parse(webviewUrl));

    // Configure platform-specific features
    if (!kIsWeb) {
      if (defaultTargetPlatform == TargetPlatform.android && widget.onAttachFile != null) {
        final androidController = controller.platform as AndroidWebViewController;
        androidController.setOnShowFileSelector((_) => widget.onAttachFile!.call());
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iOSController = controller.platform as WebKitWebViewController;
        iOSController.setAllowsBackForwardNavigationGestures(false);
      }
    }

    setState(() {
      _controller = controller;
    });
  }

  void _handleJavaScriptMessage(JavaScriptMessage jsMessage) {
    debugPrint("DOO message received: ${jsMessage.message}");
    final message = getMessage(jsMessage.message);
    
    if (isJsonString(message)) {
      try {
        final parsedMessage = jsonDecode(message);
        final eventType = parsedMessage["event"];
        final type = parsedMessage["type"];
        
        if (eventType == 'loaded') {
          final authToken = parsedMessage["config"]?["authToken"];
          if (authToken != null) {
            StoreHelper.storeCookie(authToken);
            _controller?.runJavaScript(widget.injectedJavaScript);
          }
        }
        
        // Improved close button handling with multiple event types
        if (type == 'close-widget' || type == 'close' || eventType == 'close-widget') {
          // Add a small delay to ensure the event is properly processed
          Future.microtask(() {
            widget.closeWidget?.call();
          });
        }
        
        // Handle widget toggle events as well
        if (type == 'toggle-widget' && parsedMessage["isOpen"] == false) {
          Future.microtask(() {
            widget.closeWidget?.call();
          });
        }
      } catch (e) {
        debugPrint("DOO SDK: Error parsing message: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use web-specific implementation for web platform
    if (kIsWeb) {
      // Extract parameters from widget URL for web implementation
      final uri = Uri.parse(widget.widgetUrl);
      final websiteToken = uri.queryParameters['website_token'] ?? '';
      final baseUrl = '${uri.scheme}://${uri.host}:${uri.port}';
      
      return WebWebview(
        websiteToken: websiteToken,
        baseUrl: baseUrl,
        closeWidget: widget.closeWidget,
        onAttachFile: widget.onAttachFile,
        onLoadStarted: widget.onLoadStarted,
        onLoadProgress: widget.onLoadProgress,
        onLoadCompleted: widget.onLoadCompleted,
      );
    }
    
    return _controller != null
      ? Stack(
          children: [
            WebViewWidget(controller: _controller!),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        )
      : const Center(
          child: CircularProgressIndicator(),
        );
  }

  void _goToUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  void _handleFileSelection() async {
    if (widget.onAttachFile != null) {
      try {
        List<String> files = await widget.onAttachFile!();
        if (files.isNotEmpty) {
          String fileList = files.map((file) => '"$file"').join(',');
          String script =
              'window.postMessage({"type": "file-selected", "files": [$fileList]});';
          _controller?.runJavaScript(script);
        }
      } catch (e) {
        debugPrint('Error selecting files: $e');
      }
    }
  }
}
