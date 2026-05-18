class AppStrings {
  static const String appName = 'Echo';
  static var hiveKeys = _hiveKeys();
  static var homeFeature = HomeFeature();
  static var discoverFeature = DiscoverFeature();
  static var scanFeature = ScanFeature();
  static var chatFeature = ChatFeature();
  static var profileFeature = ProfileFeature();
  static var settingsFeature = SettingsFeature();
}

class _hiveKeys {
  final dynamic cacheHelper = _cacheHelper();
}

class _cacheHelper {
  final String boxName = 'AppSettings';
  final String isOnboardingCompleted = 'isOnboardingCompleted';
  final String isLoggedIn = 'isLoggedIn';
  final String userDisplayName = 'userDisplayName';
  final String localeLanguageCode = 'localeLanguageCode';
}

class HomeFeature{
  final String key = "Home";
}

class DiscoverFeature{
  final String key = "Discover";
}

class ScanFeature{
  final String key = "Scan";
}

class ChatFeature{
  final String key = "Chat";
}

class ProfileFeature{
  final String key = "Profile";
}

class SettingsFeature{
  final String key = "Settings";
  
}

