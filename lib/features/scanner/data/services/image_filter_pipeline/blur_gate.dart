import 'dart:io';
import 'package:image/image.dart' as img;

class BlurGate {
  static const double _defaultThreshold = 50.0;

  static Future<bool> isBlurry(File imageFile, {double threshold = _defaultThreshold}) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) return true;

    final gray = img.grayscale(image);

    double variance = 0;
    int count = 0;

    for (int y = 1; y < gray.height - 1; y++) {
      for (int x = 1; x < gray.width - 1; x++) {
        final center = gray.getPixel(x, y).r.toDouble();
        final right = gray.getPixel(x + 1, y).r.toDouble();
        final left = gray.getPixel(x - 1, y).r.toDouble();
        final top = gray.getPixel(x, y - 1).r.toDouble();
        final bottom = gray.getPixel(x, y + 1).r.toDouble();

        final laplacian = (4 * center - right - left - top - bottom).abs();
        variance += laplacian * laplacian;
        count++;
      }
    }

    variance /= count;

    return variance < threshold;
  }

  static Future<double> calculateSharpness(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return 0;

    final gray = img.grayscale(image);

    double variance = 0;
    int count = 0;

    for (int y = 1; y < gray.height - 1; y++) {
      for (int x = 1; x < gray.width - 1; x++) {
        final center = gray.getPixel(x, y).r.toDouble();
        final right = gray.getPixel(x + 1, y).r.toDouble();
        final left = gray.getPixel(x - 1, y).r.toDouble();
        final top = gray.getPixel(x, y - 1).r.toDouble();
        final bottom = gray.getPixel(x, y + 1).r.toDouble();

        final laplacian = (4 * center - right - left - top - bottom).abs();
        variance += laplacian * laplacian;
        count++;
      }
    }

    return variance / count;
  }
}
