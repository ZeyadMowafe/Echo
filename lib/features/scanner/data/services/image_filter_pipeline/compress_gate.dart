import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class CompressGate {
  static Future<File> compress(File imageFile, {
    int width = 1024,
    int height = 1024,
    int quality = 75,
  }) async {
    final targetPath = '${imageFile.path}_compressed.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      imageFile.path,
      targetPath,
      minWidth: width,
      minHeight: height,
      quality: quality,
      format: CompressFormat.jpeg,
    );

    return File(result!.path);
  }
}
