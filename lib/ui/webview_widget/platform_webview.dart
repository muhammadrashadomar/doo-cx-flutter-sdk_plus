// Re-export the correct implementation per platform.
// On Web => use the real web implementation (uses dart:html / ui_web).
// Else (Android/iOS/desktop) => use a harmless stub that doesn't import web libs.
export 'web_webview_stud.dart' if (dart.library.html) 'web_webview.dart';

