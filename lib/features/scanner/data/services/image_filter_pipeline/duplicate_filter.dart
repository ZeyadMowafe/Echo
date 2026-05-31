import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class DuplicateFilter {
  static const int maxCacheSize = 5;
  static const int hammingThreshold = 5;
  final List<int> _recentHashes = [];

  bool isDuplicate(String imagePath) {
    final file = File(imagePath);
    final bytes = file.readAsBytesSync();
    return isDuplicateBytes(bytes);
  }

  bool isDuplicateBytes(Uint8List bytes) {
    final hash = _averageHash(bytes);
    if (hash == null) return false;

    for (final existing in _recentHashes) {
      final distance = _hammingDistance(hash, existing);
      if (distance < hammingThreshold) return true;
    }

    _recentHashes.add(hash);
    if (_recentHashes.length > maxCacheSize) {
      _recentHashes.removeAt(0);
    }
    return false;
  }

  static int? _averageHash(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) return null;

    final small = img.copyResize(image, width: 8, height: 8);
    final gray = img.grayscale(small);
    final pixels = gray.getBytes();
    final length = pixels.length;

    final average = pixels.reduce((a, b) => a + b) ~/ length;
    int hash = 0;
    for (int i = 0; i < length; i++) {
      if (pixels[i] > average) {
        hash |= (1 << i);
      }
    }
    return hash;
  }

  static int _hammingDistance(int a, int b) {
    int xor = a ^ b;
    int count = 0;
    while (xor != 0) {
      count += xor & 1;
      xor >>= 1;
    }
    return count;
  }

  void clear() {
    _recentHashes.clear();
  }
}
