import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for caching Universe Decipher results locally using SharedPreferences
class UniverseCacheService {
  static final UniverseCacheService _instance = UniverseCacheService._internal();
  factory UniverseCacheService() => _instance;
  UniverseCacheService._internal();

  static const String _cachePrefix = 'universe_decipher_';

  /// Get cached decipher result for a specific message
  Future<String?> getCachedResult(String messageId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_cachePrefix$messageId');
  }

  /// Cache decipher result for a specific message
  Future<void> cacheResult(String messageId, String result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_cachePrefix$messageId', result);
  }

  /// Remove cached result for a specific message
  Future<void> removeCachedResult(String messageId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_cachePrefix$messageId');
  }

  /// Clear all cached decipher results
  Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
