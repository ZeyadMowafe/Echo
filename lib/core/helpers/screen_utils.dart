import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenUtils {
  ScreenUtils._();

  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 16.w;
  static double get lg => 24.w;
  static double get xl => 32.w;
  static double get xxl => 48.w;

  static EdgeInsets get screenPadding => EdgeInsets.symmetric(horizontal: 16.w);
  static EdgeInsets get screenPaddingV => EdgeInsets.symmetric(vertical: 16.h);
  static EdgeInsets get cardPadding => EdgeInsets.all(16.r);

  static double get radiusSm => 8.r;
  static double get radiusMd => 16.r;
  static double get radiusLg => 24.r;
  static double get radiusFull => 50.r;

  static double get iconSm => 16.r;
  static double get iconMd => 22.r;
  static double get iconLg => 28.r;
  static double get iconXl => 36.r;

  static double get buttonHeight => 48.h;
  static double get fabSize => 72.r;

  static double get navBarHeight => 40.h;
  static double get glassBorderRadius => 24.r;
  static double get glassButtonSize => 34.r;
}
