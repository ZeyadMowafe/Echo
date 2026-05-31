import 'dart:async';
import 'package:echo_explorer/core/config/app_config.dart';
import 'package:sensors_plus/sensors_plus.dart';

class MotionFilter {
  final List<double> _xSamples = [];
  final List<double> _ySamples = [];
  final List<double> _zSamples = [];
  final _stabilityController = StreamController<bool>.broadcast();
  StreamSubscription? _subscription;
  Timer? _stableTimer;
  bool _isStable = false;

  bool get isStable => _isStable;
  Stream<bool> get stabilityStream => _stabilityController.stream;

  void start() {
    _subscription =
        accelerometerEventStream(samplingPeriod: const Duration(milliseconds: 50))
            .listen(_onSensorEvent);
  }

  void _onSensorEvent(AccelerometerEvent event) {
    _xSamples.add(event.x);
    _ySamples.add(event.y);
    _zSamples.add(event.z);

    if (_xSamples.length > AppConfig.motionWindowSize) _xSamples.removeAt(0);
    if (_ySamples.length > AppConfig.motionWindowSize) _ySamples.removeAt(0);
    if (_zSamples.length > AppConfig.motionWindowSize) _zSamples.removeAt(0);

    if (_xSamples.length < AppConfig.motionWindowSize) return;

    final variance = _calculateVariance(_xSamples) +
        _calculateVariance(_ySamples) +
        _calculateVariance(_zSamples);

    if (variance < AppConfig.motionVarianceThreshold) {
      _stableTimer ??= Timer(AppConfig.motionStableDuration, () {
        _isStable = true;
        _stabilityController.add(true);
      });
    } else {
      _stableTimer?.cancel();
      _stableTimer = null;
      if (_isStable) {
        _isStable = false;
        _stabilityController.add(false);
      }
    }
  }

  double _calculateVariance(List<double> samples) {
    final mean = samples.reduce((a, b) => a + b) / samples.length;
    return samples
            .map((s) => (s - mean) * (s - mean))
            .reduce((a, b) => a + b) /
        samples.length;
  }

  void stop() {
    _subscription?.cancel();
    _stableTimer?.cancel();
    _stabilityController.close();
  }
}
