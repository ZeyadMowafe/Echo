import 'dart:math' as math;
import 'dart:ui';
import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

enum AppLoadingVariant { fullScreen, page, scanner, button }

class AppLoading extends StatelessWidget {
  const AppLoading._(this.variant, {this.message});

  final AppLoadingVariant variant;
  final String? message;

  factory AppLoading.fullScreen({String? message}) =>
      AppLoading._(AppLoadingVariant.fullScreen, message: message);

  factory AppLoading.page({String? message}) =>
      AppLoading._(AppLoadingVariant.page, message: message);

  factory AppLoading.scanner() =>
      AppLoading._(AppLoadingVariant.scanner);

  factory AppLoading.button() =>
      AppLoading._(AppLoadingVariant.button);

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case AppLoadingVariant.fullScreen:
        return _FullScreenLoading(message: message);
      case AppLoadingVariant.page:
        return _PageLoading(message: message);
      case AppLoadingVariant.scanner:
        return const _ScannerLoading();
      case AppLoadingVariant.button:
        return const _ButtonLoading();
    }
  }
}

/// A premium, custom-painted spinner featuring an "Echo" ripple animation.
/// Combines dynamic soundwave expansion with dual counter-rotating gradient rings.
class PremiumEchoSpinner extends StatefulWidget {
  const PremiumEchoSpinner({
    super.key,
    required this.size,
    required this.color,
    this.strokeWidth = 3.0,
  });

  final double size;
  final Color color;
  final double strokeWidth;

  @override
  State<PremiumEchoSpinner> createState() => PremiumEchoSpinnerState();
}

class PremiumEchoSpinnerState extends State<PremiumEchoSpinner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _EchoSpinnerPainter(
            animationValue: _controller.value,
            color: widget.color,
            strokeWidth: widget.strokeWidth,
          ),
        );
      },
    );
  }
}

class _EchoSpinnerPainter extends CustomPainter {
  _EchoSpinnerPainter({
    required this.animationValue,
    required this.color,
    required this.strokeWidth,
  });

  final double animationValue;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.width / 2;

    // Use a proportional base radius for the core rotating ring
    final baseSpinnerRadius = maxRadius * 0.65;

    // 1. Draw smooth outer pulsing glow (Breathing Aura)
    final auraPaint = Paint()
      ..color = color.withValues(alpha: 0.02 + 0.02 * math.sin(animationValue * 2 * math.pi))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, maxRadius, auraPaint);

    // 2. Draw soundwave ripples (Echo waves) expanding and fading from the base circle
    if (baseSpinnerRadius < maxRadius) {
      for (int i = 0; i < 2; i++) {
        final rippleProgress = (animationValue + (i * 0.5)) % 1.0;
        final rippleRadius = baseSpinnerRadius + (maxRadius - baseSpinnerRadius) * rippleProgress;
        final rippleOpacity = (1.0 - rippleProgress) * 0.35;
        
        final ripplePaint = Paint()
          ..color = color.withValues(alpha: rippleOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawCircle(center, rippleRadius, ripplePaint);
      }
    }

    // 3. Draw static track ring
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, baseSpinnerRadius, trackPaint);

    // 4. Draw primary sweeping gradient arc (rotating clockwise)
    final double startAngle = animationValue * 2 * math.pi;
    final double sweepAngle = 1.5 * math.pi * (0.4 + 0.3 * math.sin(animationValue * math.pi));
    final rect = Rect.fromCircle(center: center, radius: baseSpinnerRadius);

    final gradientPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.5),
          color,
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(startAngle),
      ).createShader(rect);

    canvas.drawArc(rect, startAngle, sweepAngle, false, gradientPaint);

    // 5. Draw inner counter-rotating thin dashed ring (complex layered UI effect)
    final innerRadius = baseSpinnerRadius - strokeWidth * 2;
    if (innerRadius > 4) {
      final innerRect = Rect.fromCircle(center: center, radius: innerRadius);
      final double innerStartAngle = -animationValue * 3 * math.pi;
      final innerPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.5
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: 0.6);

      const double segmentAngle = 2 * math.pi / 3;
      for (int k = 0; k < 3; k++) {
        final double currentStart = innerStartAngle + k * segmentAngle;
        canvas.drawArc(innerRect, currentStart, segmentAngle * 0.45, false, innerPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EchoSpinnerPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Draws an animated, rotating gradient border for premium card components.
class _GlowingBorderPainter extends CustomPainter {
  _GlowingBorderPainter({
    required this.animationValue,
    required this.color,
    required this.borderRadius,
  });

  final double animationValue;
  final Color color;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = SweepGradient(
        colors: [
          color.withValues(alpha: 0.15),
          color.withValues(alpha: 0.8),
          color,
          color.withValues(alpha: 0.8),
          color.withValues(alpha: 0.15),
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        transform: GradientRotation(animationValue * 2 * math.pi),
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GlowingBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius;
  }
}

/// A text widget that breathes in opacity smoothly during loading operations.
class _BreathingText extends StatefulWidget {
  const _BreathingText({required this.text, required this.style});
  final String text;
  final TextStyle style;

  @override
  State<_BreathingText> createState() => _BreathingTextState();
}

class _BreathingTextState extends State<_BreathingText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Text(
        widget.text,
        style: widget.style,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _FullScreenLoading extends StatefulWidget {
  const _FullScreenLoading({this.message});
  final String? message;

  @override
  State<_FullScreenLoading> createState() => _FullScreenLoadingState();
}

class _FullScreenLoadingState extends State<_FullScreenLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.black.withValues(alpha: 0.5)),
        Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Smooth breathing scale for the entire card (0.98 to 1.02)
              final scale = 1.0 + 0.02 * math.sin(_controller.value * 2 * math.pi);
              return Transform.scale(
                scale: scale,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: AppDimensions.glassSigma,
                      sigmaY: AppDimensions.glassSigma,
                    ),
                    child: CustomPaint(
                      painter: _GlowingBorderPainter(
                        animationValue: _controller.value,
                        color: AppColors.secondary,
                        borderRadius: 24.r,
                      ),
                      child: Container(
                        width: 150.r,
                        height: 150.r,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.r),
                          color: AppColors.cffffff.withValues(alpha: 0.03),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.cffffff.withValues(alpha: 0.05),
                              AppColors.cffffff.withValues(alpha: 0.01),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PremiumEchoSpinner(
                              size: 52.r,
                              color: AppColors.secondary,
                              strokeWidth: 3.5,
                            ),
                            if (widget.message != null) ...[
                              Gap(14.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                child: _BreathingText(
                                  text: widget.message!,
                                  style: TextStyle(
                                    color: AppColors.cffffff.withValues(alpha: 0.85),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PageLoading extends StatelessWidget {
  const _PageLoading({this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PremiumEchoSpinner(
            size: 56.r,
            color: AppColors.secondary,
            strokeWidth: 3.5,
          ),
          if (message != null) ...[
            Gap(18.h),
            _BreathingText(
              text: message!,
              style: TextStyle(
                color: AppColors.of(context).footer.withValues(alpha: 0.75),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScannerLoading extends StatelessWidget {
  const _ScannerLoading();

  @override
  Widget build(BuildContext context) {
    return PremiumEchoSpinner(
      size: 24.r,
      color: AppColors.secondary,
      strokeWidth: 2.2,
    );
  }
}

class _ButtonLoading extends StatelessWidget {
  const _ButtonLoading();

  @override
  Widget build(BuildContext context) {
    return const PremiumEchoSpinner(
      size: 20,
      color: Colors.white,
      strokeWidth: 2.0,
    );
  }
}

/// A highly polished, futuristic scanning overlay.
/// Features a moving laser sweep, animated grid background, rotating reticle target,
/// and sequential technical scanning statuses to wow the user.
class FuturisticScanAnalyzerOverlay extends StatefulWidget {
  final List<String> steps;
  const FuturisticScanAnalyzerOverlay({super.key, required this.steps});

  @override
  State<FuturisticScanAnalyzerOverlay> createState() => _FuturisticScanAnalyzerOverlayState();
}

class _FuturisticScanAnalyzerOverlayState extends State<FuturisticScanAnalyzerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _laserPosition;
  late Animation<double> _pulseOpacity;
  int _currentStepIndex = 0;

  List<String> get _scanSteps => widget.steps;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _laserPosition = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _pulseOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.2, end: 0.7), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 0.7, end: 0.2), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    // Dynamic step progression synchronized with the loop
    _controller.addListener(() {
      final newIndex = (_controller.value * _scanSteps.length).floor().clamp(0, _scanSteps.length - 1);
      if (newIndex != _currentStepIndex) {
        setState(() {
          _currentStepIndex = newIndex;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.6), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Stack(
          children: [
            // 1. Futuristic Grid Overlay
            AnimatedBuilder(
              animation: _pulseOpacity,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _FuturisticGridPainter(
                    opacity: _pulseOpacity.value,
                    color: AppColors.secondary,
                  ),
                );
              },
            ),

            // 2. Central target/reticle indicator rotating continuously
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _controller.value * 2 * math.pi,
                    child: CustomPaint(
                      size: Size(160.r, 160.r),
                      painter: _ReticlePainter(
                        color: AppColors.secondary.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 3. Central Glassmorphic Status Overlay
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: 220.w,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      color: Colors.black.withValues(alpha: 0.65),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PremiumEchoSpinner(
                          size: 44.r,
                          color: AppColors.secondary,
                          strokeWidth: 3.0,
                        ),
                        Gap(16.h),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          child: Text(
                            _scanSteps[_currentStepIndex],
                            key: ValueKey<String>(_scanSteps[_currentStepIndex]),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 4. Moving Laser Beam
            AnimatedBuilder(
              animation: _laserPosition,
              builder: (context, child) {
                // Moving back and forth smoothly inside crop area
                final double pingPongValue = 0.5 + 0.5 * math.sin(_controller.value * 2 * math.pi - math.pi / 2);
                final topOffset = pingPongValue * 440.h; // slightly inset to avoid clipping borders
                return Positioned(
                  top: topOffset,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Laser Line Glow
                      Container(
                        height: 2.h,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.8),
                              blurRadius: 10.r,
                              spreadRadius: 2.r,
                            ),
                          ],
                        ),
                      ),
                      // Soft trail
                      Container(
                        height: 12.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.secondary.withValues(alpha: 0.18),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FuturisticGridPainter extends CustomPainter {
  final double opacity;
  final Color color;

  _FuturisticGridPainter({required this.opacity, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity * 0.08)
      ..strokeWidth = 0.5;

    // Draw horizontal grid lines
    const double step = 20.0;
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Draw vertical grid lines
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FuturisticGridPainter oldDelegate) {
    return oldDelegate.opacity != opacity || oldDelegate.color != color;
  }
}

class _ReticlePainter extends CustomPainter {
  final Color color;

  _ReticlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw central circular reticles
    canvas.drawCircle(center, size.width * 0.45, paint);

    // Draw outer dotted circle (using short arcs)
    final double dashRadius = size.width * 0.35;
    final rect = Rect.fromCircle(center: center, radius: dashRadius);
    final dashedPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 8; i++) {
      canvas.drawArc(rect, i * math.pi / 4, math.pi / 12, false, dashedPaint);
    }

    // Draw crosshair ticks
    final double tickLength = 10.0;
    // Top
    canvas.drawLine(
      Offset(center.dx, center.dy - size.width * 0.45),
      Offset(center.dx, center.dy - size.width * 0.45 + tickLength),
      paint,
    );
    // Bottom
    canvas.drawLine(
      Offset(center.dx, center.dy + size.width * 0.45),
      Offset(center.dx, center.dy + size.width * 0.45 - tickLength),
      paint,
    );
    // Left
    canvas.drawLine(
      Offset(center.dx - size.width * 0.45, center.dy),
      Offset(center.dx - size.width * 0.45 + tickLength, center.dy),
      paint,
    );
    // Right
    canvas.drawLine(
      Offset(center.dx + size.width * 0.45, center.dy),
      Offset(center.dx + size.width * 0.45 - tickLength, center.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ReticlePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
