enum PipelineRejection { none, unstable, blurry, throttled }

class PipelineResult {
  final PipelineRejection rejection;
  final double? sharpness;
  final String? message;

  const PipelineResult._(this.rejection, {this.sharpness, this.message});

  static const passed = PipelineResult._(PipelineRejection.none);

  const PipelineResult.unstable([String? msg])
      : this._(PipelineRejection.unstable, message: msg);

  const PipelineResult.blurry(double s)
      : this._(PipelineRejection.blurry, sharpness: s);

  const PipelineResult.throttled([String? msg])
      : this._(PipelineRejection.throttled, message: msg);
}
