import 'dart:ui';
import 'package:echo_explorer/core/constants/app_dimensions.dart';
import 'package:flutter/material.dart';

class CustomGlassContainer extends StatelessWidget {
  const CustomGlassContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.color,
    this.borderColor,
    this.gradient,
    this.margin,
    this.width,
    this.height, this.sigmaX =AppDimensions.glassSigma, this.sigmaY =AppDimensions.glassSigma,
  });

  final Widget child;
  final BorderRadiusGeometry? borderRadius;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Gradient? gradient;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double? sigmaX;
  final double? sigmaY;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(0),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: sigmaX ?? AppDimensions.glassSigma,
          sigmaY: sigmaY ?? AppDimensions.glassSigma,
        ),
        child: Container(
          width: width,
          height: height,
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? Colors.transparent,
            gradient: gradient,
            borderRadius: borderRadius,
            border: borderColor != null
                ? Border.all(
                    color: borderColor!,
                    width: AppDimensions.borderWidth,
                    strokeAlign:
                        BorderSide.strokeAlignInside, // border من جوه بس
                  )
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
