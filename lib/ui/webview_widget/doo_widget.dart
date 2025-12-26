import 'package:doo_cx_flutter_sdk_plus/data/local/entity/doo_user.dart';
import 'package:doo_cx_flutter_sdk_plus/ui/webview_widget/webview.dart';
import 'package:flutter/material.dart';

/// DOOWidget is a ready-to-use webview component that displays the DOO chat interface
///
/// This widget provides a full-featured chat experience that can be embedded directly
/// into your Flutter application. It handles user authentication, file attachments,
/// and event callbacks to integrate seamlessly with your app.
///
/// {@category FlutterClientSdk}
class DOOWidget extends StatefulWidget {
  /// Website channel token for authentication
  final String websiteToken;

  /// Base URL of your DOO installation (e.g., "https://cx.doo.ooo")
  final String baseUrl;

  /// User information including identifier, name, email, and avatar URL
  final DOOUser? user;

  /// User locale for localization (defaults to "en")
  final String locale;

  /// Callback triggered when the widget is closed
  final void Function()? closeWidget;

  /// Additional information about the customer (optional)
  final dynamic customAttributes;

  /// Callback to handle file attachment selection
  ///
  /// Should return a list of file URIs (currently supported only on Android devices)
  final Future<List<String>> Function()? onAttachFile;

  /// Callback triggered when the widget starts loading
  final void Function()? onLoadStarted;

  /// Callback triggered during widget loading with progress percentage
  final void Function(int)? onLoadProgress;

  /// Callback triggered when the widget finishes loading
  final void Function()? onLoadCompleted;

  /// Creates a DOOWidget instance with the specified configuration
  ///
  /// [websiteToken] and [baseUrl] are required parameters.
  /// Providing [user] details is recommended for user identification.
  const DOOWidget(
      {Key? key,
      required this.websiteToken,
      required this.baseUrl,
      this.user,
      this.locale = "en",
      this.customAttributes,
      this.closeWidget,
      this.onAttachFile,
      this.onLoadStarted,
      this.onLoadProgress,
      this.onLoadCompleted})
      : super(key: key);

  @override
  _DOOWidgetState createState() => _DOOWidgetState();
}

class _DOOWidgetState extends State<DOOWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Webview(
      websiteToken: widget.websiteToken,
      baseUrl: widget.baseUrl,
      user: widget.user,
      locale: widget.locale,
      customAttributes: widget.customAttributes,
      closeWidget: widget.closeWidget,
      onAttachFile: widget.onAttachFile,
      onLoadStarted: widget.onLoadStarted,
      onLoadCompleted: widget.onLoadCompleted,
      onLoadProgress: widget.onLoadProgress,
    );
  }
}
