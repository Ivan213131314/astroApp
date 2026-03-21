import 'package:flutter/foundation.dart';

/// Debug configuration for development
/// Set all flags to false before production release!

class DebugConfig {
  DebugConfig._();

  /// Skip Superwall paywall and simulate successful purchase
  /// Set to false for production!
  static const bool skipPaywall = false;

  /// Enable debug logging
  static const bool enableLogging = true;

  /// Enable verbose Superwall diagnostics only in debug builds.
  static bool get enableSuperwallDiagnostics => kDebugMode && enableLogging;

  /// Log debug message if logging is enabled
  static void log(String message) {
    if (enableSuperwallDiagnostics) {
      debugPrint('[DEBUG] $message');
    }
  }
}

