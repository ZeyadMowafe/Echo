import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:echo_explorer/core/hive/cache_helper.dart';
import 'package:echo_explorer/features/scanner/data/models/scan_response_model.dart';
import 'package:echo_explorer/features/scanner/domain/entities/scan_response_entity.dart';
import 'package:image/image.dart' as img;

class DuplicateGate {
  static const String _hashPrefix = 'image_hash_';
  static const String _fullDataPrefix = 'scanFullData_';

  /// Compute perceptual hash (8×8 average hash) from image file
  static Future<String> computeHash(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return _averageHash(bytes);
  }

  static String _averageHash(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) return '';

    final small = img.copyResize(image, width: 8, height: 8);
    final gray = img.grayscale(small);
    final pixels = gray.getBytes();
    final length = pixels.length;

    final average = pixels.reduce((a, b) => a + b) ~/ length;
    int hash = 0;
    for (int i = 0; i < length; i++) {
      if (pixels[i] > average) hash |= (1 << i);
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }

  /// Check if this image hash has been scanned before.
  /// Returns the cached [ScanResponseEntity] if found, null otherwise.
  static ScanResponseEntity? getCachedResult(String hash) {
    final scanLogId = CacheHelper.getData(key: '$_hashPrefix$hash') as String?;
    if (scanLogId == null) return null;

    final fullJson =
        CacheHelper.getData(key: '$_fullDataPrefix$scanLogId') as String?;
    if (fullJson == null) return null;

    try {
      final json = jsonDecode(fullJson) as Map<String, dynamic>;
      return ScanResponseModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Store the scan result and its image hash for future duplicate detection.
  static void cacheResult(
    String hash,
    String scanLogId,
    ScanResponseEntity response,
  ) {
    final fullData = {
      'status': response.status,
      'processingTimeMs': response.processingTimeMs,
      'scanLogId': response.scanLogId,
      'artifact': {
        'isPrimaryModel': response.artifact.isPrimaryModel,
        'artifactModelId': response.artifact.artifactModelId,
        'name': response.artifact.name,
        'description': response.artifact.description,
        'era': response.artifact.era,
        'material': response.artifact.material,
        'category': response.artifact.category,
        'type': response.artifact.type,
        'imageUrl': response.artifact.imageUrl,
      },
      'hieroglyphs': response.hieroglyphs != null
          ? {
              'detected': response.hieroglyphs!.detected,
              'translation': response.hieroglyphs!.translation,
              'translationMethod': response.hieroglyphs!.translationMethod,
              'stats': {
                'totalLines': response.hieroglyphs!.totalLines,
                'totalGlyphs': response.hieroglyphs!.totalGlyphs,
                'cartoucheCount': response.hieroglyphs!.cartoucheCount,
                'royalNames': response.hieroglyphs!.royalNames,
              },
            }
          : null,
    };

    CacheHelper.putData(key: '$_hashPrefix$hash', value: scanLogId);
    CacheHelper.putData(
      key: '$_fullDataPrefix$scanLogId',
      value: jsonEncode(fullData),
    );
  }

  /// Remove all cached data for a given hash (for testing/cleanup).
  static void invalidate(String hash) {
    final scanLogId = CacheHelper.getData(key: '$_hashPrefix$hash');
    if (scanLogId != null) {
      CacheHelper.deleteData(key: '$_fullDataPrefix$scanLogId');
    }
    CacheHelper.deleteData(key: '$_hashPrefix$hash');
  }
}
