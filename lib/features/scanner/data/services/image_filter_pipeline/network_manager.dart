import 'dart:async';
import 'package:echo_explorer/core/config/app_config.dart';

typedef NetworkTask = Future<void> Function();

class NetworkManager {
  bool _isUploading = false;
  NetworkTask? _pendingTask;
  DateTime? _cooldownUntil;
  Timer? _cooldownTimer;
  bool _isPaused = false;
  final _cooldownController = StreamController<bool>.broadcast();

  bool get isUploading => _isUploading;
  bool get isPaused => _isPaused;
  bool get isInCooldown =>
      _cooldownUntil != null && DateTime.now().isBefore(_cooldownUntil!);
  bool get canEnqueue => !_isUploading && !isInCooldown && !_isPaused;
  Stream<bool> get cooldownStream => _cooldownController.stream;

  Future<void> enqueue(NetworkTask task) async {
    if (_isPaused) return;
    if (isInCooldown) return;
    _pendingTask = task;
    if (_isUploading) return;
    await _processQueue();
  }

  void _startCooldown() {
    _cooldownUntil = DateTime.now().add(AppConfig.networkCooldown);
    _cooldownController.add(true);
    _cooldownTimer = Timer(AppConfig.networkCooldown, () {
      _cooldownUntil = null;
      _cooldownController.add(false);
    });
  }

  Future<void> _processQueue() async {
    while (_pendingTask != null && !_isPaused) {
      _isUploading = true;
      final task = _pendingTask!;
      _pendingTask = null;

      for (int attempt = 0; attempt < AppConfig.networkMaxRetries; attempt++) {
        try {
          await task();
          _isUploading = false;
          return;
        } catch (_) {
          if (attempt < AppConfig.networkMaxRetries - 1) {
            await Future.delayed(Duration(seconds: 1 << attempt));
          }
        }
      }
      _startCooldown();
    }
    _isUploading = false;
  }

  /// Called when backend returns success → Gate 4: pause scanning.
  void pauseScanning() {
    _isPaused = true;
    _pendingTask = null;
    _isUploading = false;
    _cooldownTimer?.cancel();
    _cooldownUntil = null;
  }

  /// Called when user moves camera away → resume scanning.
  void resumeScanning() {
    _isPaused = false;
  }

  void cancelPending() {
    _pendingTask = null;
    _cooldownTimer?.cancel();
    _cooldownUntil = null;
  }

  void reset() {
    cancelPending();
    _isPaused = false;
    _isUploading = false;
  }

  void dispose() {
    cancelPending();
    _cooldownController.close();
  }
}
