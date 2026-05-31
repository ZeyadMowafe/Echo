import 'dart:async';
import 'dart:io';
import 'package:echo_explorer/core/config/app_config.dart';
import 'package:echo_explorer/features/scanner/data/services/image_filter_pipeline/blur_filter.dart';
import 'package:echo_explorer/features/scanner/data/services/image_filter_pipeline/duplicate_filter.dart';
import 'package:echo_explorer/features/scanner/data/services/image_filter_pipeline/motion_filter.dart';
import 'package:echo_explorer/features/scanner/data/services/image_filter_pipeline/network_manager.dart';
import 'package:echo_explorer/features/scanner/data/services/image_filter_pipeline/pipeline.dart';
import 'package:flutter/foundation.dart';

class ScanPipeline {
  final MotionFilter motionFilter;
  final NetworkManager networkManager;
  final DuplicateFilter duplicateFilter;

  ScanPipeline({
    required this.motionFilter,
    required this.networkManager,
    DuplicateFilter? duplicateFilter,
  }) : duplicateFilter = duplicateFilter ?? DuplicateFilter();

  StreamSubscription? _motionSub;
  bool _isStable = false;

  Stream<bool> get stabilityStream => motionFilter.stabilityStream;
  Stream<bool> get cooldownStream => networkManager.cooldownStream;
  bool get isPaused => networkManager.isPaused;
  bool get isStable => _isStable;

  void startMotionDetection() {
    _motionSub = motionFilter.stabilityStream.listen((s) => _isStable = s);
    motionFilter.start();
  }

  void stopMotionDetection() {
    _motionSub?.cancel();
    motionFilter.stop();
  }

  /// Returns a [PipelineResult] — callers must check `.rejection`.
  Future<PipelineResult> runFilters(String imagePath) async {
    // ── Gate 1: Motion & Stability ──
    if (!_isStable) {
      return const PipelineResult.unstable('Device is not stable');
    }

    final file = File(imagePath);
    if (!await file.exists()) {
      return const PipelineResult.unstable('Image file not found');
    }

    // ── Gate 2: Blur Detection ──
    try {
      final sharpness = await compute(BlurFilter.calculateSharpness, imagePath);
      if (sharpness < AppConfig.blurSharpnessThreshold) {
        return PipelineResult.blurry(sharpness);
      }
    } catch (_) {}

    // ── Gate 3a: Duplicate Detection ──
    try {
      if (duplicateFilter.isDuplicate(imagePath)) {
        return const PipelineResult.throttled('Duplicate image');
      }
    } catch (_) {}

    // ── Gate 3b: Network Throttling (in-flight + cooldown) ──
    if (!networkManager.canEnqueue) {
      if (networkManager.isUploading) {
        return const PipelineResult.throttled('Request in flight');
      }
      if (networkManager.isInCooldown) {
        return const PipelineResult.throttled('Cooldown active');
      }
      if (networkManager.isPaused) {
        return const PipelineResult.throttled('Scanning paused');
      }
    }

    return PipelineResult.passed;
  }

  void onSuccess() {
    networkManager.pauseScanning();
    duplicateFilter.clear();
  }

  void onFailure() {
    // cooldown auto-starts inside networkManager on all-retry-fail
  }

  void onPanAway() {
    networkManager.resumeScanning();
  }

  void reset() {
    networkManager.reset();
    duplicateFilter.clear();
  }

  void dispose() {
    stopMotionDetection();
    networkManager.dispose();
  }
}
