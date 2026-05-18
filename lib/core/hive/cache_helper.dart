import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:hive/hive.dart';

class CacheHelper {
  static var isOnboardingCompleted;
  static final String _appSettingsBox = AppStrings.hiveKeys.cacheHelper.boxName;
  static Future<void> putData({
    required String key,
    required dynamic value,
  }) async {
    var box = Hive.box(_appSettingsBox);
    await box.put(key, value);
  }

  static dynamic getData({required String key, dynamic defaultValue}) {
    var box = Hive.box(_appSettingsBox);
    return box.get(key, defaultValue: defaultValue);
  }

  static Future<void> deleteData({required String key}) async {
    var box = Hive.box(_appSettingsBox);
    await box.delete(key);
  }
}
