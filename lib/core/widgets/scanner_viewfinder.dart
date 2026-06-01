import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:echo_explorer/core/constants/app_colors.dart';

/// A professional scanner viewfinder overlay.
/// Draws pulsing corners and a moving laser line with light trail.
class ScannerViewfinder extends StatefulWidget {
  final double width;
  final double height;
  final bool animate;

  const ScannerViewfinder({
    super.key,
    required this.width,
    required this.height,
    this.animate = true,
  });

  @override
  State<ScannerViewfinder> createState() => _ScannerViewfinderState();
}

class _ScannerViewfinderState extends State<ScannerViewfinder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _laserPosition;
  late Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _laserPosition = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _pulseOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.35, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.35), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ScannerViewfinder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          // Viewfinder Corners
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _pulseOpacity,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.width, widget.height),
                  painter: _ViewfinderPainter(
                    color: AppColors.secondary.withOpacity(_pulseOpacity.value),
                    strokeWidth: 3.r,
                    borderRadius: 12.r,
                    cornerLength: 20.r,
                  ),
                );
              },
            ),
          ),
          // Laser line animation
          if (widget.animate)
            RepaintBoundary(
              child: AnimatedBuilder(
              animation: _laserPosition,
              builder: (context, child) {
                final topOffset = _laserPosition.value * (widget.height - 14.h);
                return Positioned(
                  top: topOffset,
                  left: 4.w,
                  right: 4.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Glowing laser line
                      Container(
                        height: 2.h,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.8),
                              blurRadius: 8.r,
                              spreadRadius: 1.5.r,
                            ),
                          ],
                        ),
                      ),
                      // Soft gradient glow trailing the laser
                      Container(
                        height: 12.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.secondary.withOpacity(0.15),
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
            ),
        ],
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double borderRadius;
  final double cornerLength;

  _ViewfinderPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
    required this.cornerLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Top-Left Corner
    path.moveTo(0, cornerLength);
    path.lineTo(0, borderRadius);
    path.quadraticBezierTo(0, 0, borderRadius, 0);
    path.lineTo(cornerLength, 0);

    // Top-Right Corner
    path.moveTo(size.width - cornerLength, 0);
    path.lineTo(size.width - borderRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, borderRadius);
    path.lineTo(size.width, cornerLength);

    // Bottom-Right Corner
    path.moveTo(size.width, size.height - cornerLength);
    path.lineTo(size.width, size.height - borderRadius);
    path.quadraticBezierTo(size.width, size.height, size.width - borderRadius, size.height);
    path.lineTo(size.width - cornerLength, size.height);

    // Bottom-Left Corner
    path.moveTo(cornerLength, size.height);
    path.lineTo(borderRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - borderRadius);
    path.lineTo(0, size.height - cornerLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ViewfinderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.cornerLength != cornerLength;
  }
}
