class AppConfig {
  static const String appName = 'Echo';
  static const Duration connectTimeout = Duration(seconds: 120);
  static const Duration receiveTimeout = Duration(seconds: 120);

  // ── Blur Detection ──
  static const double blurThreshold = 50.0;

  // ── Image Compression ──
  static const int compressMaxWidth = 1024;
  static const int compressMaxHeight = 1024;
  static const int compressQuality = 75;
}
