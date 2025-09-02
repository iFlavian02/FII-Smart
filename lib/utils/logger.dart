import 'package:flutter/foundation.dart';

class Logger {
  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      if (tag != null) {
        print('[$tag] $message');
      } else {
        print(message);
      }
    }
  }
  
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('ERROR: $message');
      if (error != null) {
        print('$error');
      }
      if (stackTrace != null) {
        print('$stackTrace');
      }
    }
  }
  
  static void warn(String message) {
    if (kDebugMode) {
      print('WARNING: $message');
    }
  }
  
  static void info(String message) {
    if (kDebugMode) {
      print('INFO: $message');
    }
  }
  
  static void debug(String message) {
    if (kDebugMode) {
      print('DEBUG: $message');
    }
  }
}
