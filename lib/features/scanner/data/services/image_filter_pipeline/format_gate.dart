import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class FormatGate {
  static Future<File> ensureJpeg(File imageFile) async {
    final extension = imageFile.path.split('.').last.toLowerCase();

    if (extension == 'jpg' || extension == 'jpeg') {
      return imageFile;
    }

    final jpegPath = imageFile.path.replaceAll('.$extension', '.jpg');

    final result = await FlutterImageCompress.compressAndGetFile(
      imageFile.path,
      jpegPath,
      format: CompressFormat.jpeg,
      quality: 90,
    );

    return File(result!.path);
  }
}
