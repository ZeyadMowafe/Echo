import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class BlurFilter {
  static const double defaultThreshold = 150.0;

  static Future<double> calculateSharpness(String imagePath) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    return _calculateSharpnessFromBytes(bytes);
  }

  static double calculateSharpnessFromBytes(Uint8List bytes) {
    return _calculateSharpnessFromBytes(bytes);
  }

  static double _calculateSharpnessFromBytes(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) return 0;

    // Downscale to max 640px on the longest side for fast Laplacian
    final small = (image.width > 640 || image.height > 640)
        ? img.copyResize(image, width: image.width >= image.height ? 640 : null, height: image.height > image.width ? 640 : null)
        : image;

    final gray = img.grayscale(small);

    // Laplacian kernel: [0, -1, 0; -1, 4, -1; 0, -1, 0]
    const kernel = [0, -1, 0, -1, 4, -1, 0, -1, 0];
    final laplacian = img.convolution(gray, filter: kernel, div: 1, offset: 0);

    var sum = 0.0;
    var sumSq = 0.0;
    var count = 0;
    for (final pixel in laplacian) {
      final v = pixel.r.toDouble();
      sum += v;
      sumSq += v * v;
      count++;
    }

    if (count == 0) return 0;
    final mean = sum / count;
    final variance = (sumSq / count) - (mean * mean);
    return variance;
  }

  static Future<bool> isBlurry(String imagePath, {double threshold = defaultThreshold}) async {
    final sharpness = await calculateSharpness(imagePath);
    return sharpness < threshold;
  }
}
