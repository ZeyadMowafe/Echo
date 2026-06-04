class AppConfig {
  static const String appName = 'Echo';
  static const Duration connectTimeout = Duration(seconds: 120);
  static const Duration receiveTimeout = Duration(seconds: 120);

  // ── Scan Pipeline ──
  static const double motionVarianceThreshold = 3.0;
  static const int motionWindowSize = 30;
  static const Duration motionStableDuration = Duration(milliseconds: 300);

  static const double blurSharpnessThreshold = 150.0;

  static const Duration networkCooldown = Duration(seconds: 2);
  static const int networkMaxRetries = 1;

  static const double panResetCosineThreshold = 0.75;
}
