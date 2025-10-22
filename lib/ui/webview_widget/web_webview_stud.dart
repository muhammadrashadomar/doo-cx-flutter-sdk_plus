import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Non-web fallback for the web widget.
/// Keeps the same public API as the real web implementation so imports don’t break.
class WebWebview extends StatelessWidget {
  final String websiteToken;
  final String baseUrl;
  final void Function()? closeWidget;
  final Future<List<String>> Function()? onAttachFile;
  final void Function()? onLoadStarted;
  final void Function(int)? onLoadProgress;
  final void Function()? onLoadCompleted;

  const WebWebview({
    super.key,
    required this.websiteToken,
    required this.baseUrl,
    this.closeWidget,
    this.onAttachFile,
    this.onLoadStarted,
    this.onLoadProgress,
    this.onLoadCompleted,
  });

  @override
  Widget build(BuildContext context) {
    // Option A: compile-only stub (renders nothing on non-web)
    // return const SizedBox.shrink();

    // Option B: tiny notice in debug to make it obvious during testing
    return kDebugMode
        ? Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.redAccent),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'DOO Web widget is only available on Web builds.',
              style: TextStyle(fontSize: 12),
            ),
          )
        : const SizedBox.shrink();
  }
}
