import 'dart:io';
import 'package:echo_explorer/features/scanner/data/services/image_filter_pipeline/blur_gate.dart';
import 'package:echo_explorer/features/scanner/data/services/image_filter_pipeline/compress_gate.dart';
import 'package:echo_explorer/features/scanner/data/services/image_filter_pipeline/debounce_gate.dart';
import 'package:echo_explorer/features/scanner/data/services/image_filter_pipeline/format_gate.dart';

enum PhotoRejection { blurry, debounced }

class ProcessedPhotoResult {
  final File? file;
  final PhotoRejection? rejection;
  final double? sharpness;
  final String? message;

  const ProcessedPhotoResult._({this.file, this.rejection, this.sharpness, this.message});

  static ProcessedPhotoResult passed(File file) =>
      ProcessedPhotoResult._(file: file);

  static ProcessedPhotoResult blurry(double sharpness) =>
      ProcessedPhotoResult._(
        rejection: PhotoRejection.blurry,
        sharpness: sharpness,
        message: 'Image too blurry (sharpness: ${sharpness.toStringAsFixed(0)})',
      );

  static ProcessedPhotoResult debounced() =>
      const ProcessedPhotoResult._(
        rejection: PhotoRejection.debounced,
        message: 'Please wait',
      );
}

class PhotoPipeline {
  final DebounceGate debounceGate;

  PhotoPipeline({DebounceGate? debounceGate})
      : debounceGate = debounceGate ?? DebounceGate();

  Future<ProcessedPhotoResult> processPhoto(File imageFile) async {
    if (!debounceGate.canProceed) {
      return ProcessedPhotoResult.debounced();
    }
    debounceGate.lock();

    try {
      final blurry = await BlurGate.isBlurry(imageFile);
      if (blurry) {
        final sharpness = await BlurGate.calculateSharpness(imageFile);
        return ProcessedPhotoResult.blurry(sharpness);
      }

      var file = await FormatGate.ensureJpeg(imageFile);
      file = await CompressGate.compress(file);

      return ProcessedPhotoResult.passed(file);
    } finally {
      debounceGate.unlock();
    }
  }

  void reset() {
    debounceGate.reset();
  }
}
