import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class CacheHelper {
  static var isOnboardingCompleted;
  static final String _appSettingsBox = AppStrings.hiveKeys.cacheHelper.boxName;
  static final _memoryCache = <String, dynamic>{};

  static Future<void> putData({
    required String key,
    required dynamic value,
  }) async {
    _memoryCache[key] = value;
    try {
      var box = Hive.box(_appSettingsBox);
      await box.put(key, value);
    } catch (e) {
      debugPrint('[CacheHelper] putData failed: $e');
    }
  }

  static dynamic getData({required String key, dynamic defaultValue}) {
    if (_memoryCache.containsKey(key)) return _memoryCache[key] ?? defaultValue;
    try {
      var box = Hive.box(_appSettingsBox);
      final value = box.get(key, defaultValue: defaultValue);
      _memoryCache[key] = value;
      return value;
    } catch (e) {
      debugPrint('[CacheHelper] getData failed: $e');
      return defaultValue;
    }
  }

  static Future<void> deleteData({required String key}) async {
    _memoryCache.remove(key);
    try {
      var box = Hive.box(_appSettingsBox);
      await box.delete(key);
    } catch (e) {
      debugPrint('[CacheHelper] deleteData failed: $e');
    }
  }
}
