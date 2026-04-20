import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void debug(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message${error != null ? '\n$error' : ''}');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[INFO] $message');
    }
  }

  static void warning(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('[WARN] $message${error != null ? '\n$error' : ''}');
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message${error != null ? '\n$error' : ''}');
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
  }
}
