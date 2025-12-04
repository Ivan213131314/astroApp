/// Debug configuration for development
/// Set all flags to false before production release!

class DebugConfig {
  DebugConfig._();

  /// Skip Superwall paywall and simulate successful purchase
  /// Set to false for production!
  static const bool skipPaywall = true;

  /// Enable debug logging
  static const bool enableLogging = true;

  /// Log debug message if logging is enabled
  static void log(String message) {
    if (enableLogging) {
      print('[DEBUG] $message');
    }
  }
}







