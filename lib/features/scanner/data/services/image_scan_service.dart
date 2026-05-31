import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageScanService {
  CameraController? _cameraController;
  bool _isCameraReady = false;

  final Dio dio;

  ImageScanService({required this.dio});

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) throw Exception('No camera found');

    final back = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      back,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _cameraController!.initialize();
    _isCameraReady = true;
  }

  CameraController? get cameraController => _cameraController;
  bool get isCameraReady => _isCameraReady;

  Future<File> capturePhoto({bool flash = false}) async {
    if (!_isCameraReady) throw Exception('Camera not ready');
    if (flash) {
      await _cameraController!.setFlashMode(FlashMode.always);
    }
    final photo = await _cameraController!.takePicture();
    if (flash) {
      await _cameraController!.setFlashMode(FlashMode.off);
    }
    return File(photo.path);
  }

  Future<Uint8List> compressImage(File file, {int quality = 90}) async {
    final compressed = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: quality,
      format: CompressFormat.jpeg,
    );
    return compressed ?? await file.readAsBytes();
  }

  Future<Response> sendToBackend({
    required Uint8List imageBytes,
    required String fileName,
    required String language,
    required String endpoint,
  }) async {
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(imageBytes, filename: fileName),
    });
    return dio.post(
      '$endpoint?lang=$language',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        receiveTimeout: const Duration(seconds: 120),
        connectTimeout: const Duration(seconds: 60),
      ),
    );
  }

  Future<bool> toggleFlash() async {
    if (!_isCameraReady) return false;
    final currentMode = _cameraController!.value.flashMode;
    final newMode = currentMode == FlashMode.always ? FlashMode.off : FlashMode.always;
    await _cameraController!.setFlashMode(newMode);
    return newMode == FlashMode.always;
  }

  void dispose() {
    _cameraController?.dispose();
    _cameraController = null;
    _isCameraReady = false;
  }
}