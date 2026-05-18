import 'dart:ui';
import "package:flutter/material.dart";

class CustomGlassContainer extends StatelessWidget {
    const CustomGlassContainer({super.key,required this.child, this.borderRadius, this.padding,this.color,this.borderColor,this.gradient,this.margin,this.width,this.height});
    final Widget child;
  final BorderRadiusGeometry? borderRadius;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Gradient? gradient;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius??BorderRadius.circular(0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          height: height,
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            color: color??Colors.transparent,
            gradient: gradient,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor??Colors.transparent, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
