import 'package:flutter/foundation.dart';

/// A safe logging utility that only prints in debug mode.
/// This prevents sensitive information from being leaked in production logs.
void safePrint(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}
