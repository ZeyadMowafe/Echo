import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomGlassBackButton extends StatelessWidget {
  const CustomGlassBackButton({
    super.key,
    required this.onPressed,
    this.size = 34,
    this.iconSize = 22,
    this.iconColor,
    this.rtlAware = true,
  });

  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? iconColor;
  final bool rtlAware;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final color = iconColor ?? appColors.footer;
    final icon = rtlAware && Directionality.of(context) == TextDirection.rtl
        ? Icons.arrow_forward_rounded
        : Icons.arrow_back_rounded;

    return CustomGlassContainer(
      width: size.w,
      height: size.h,
      borderRadius: BorderRadius.circular(50.r),
      borderColor: appColors.glassBase.withValues(alpha: 0.10),
      color: appColors.glassBase.withValues(alpha: 0.10),
      gradient: LinearGradient(
        colors: [
          appColors.glassBase.withValues(alpha: 0.20),
          appColors.glassBase.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      child: CustomGlassContainer(
        width: size.w,
        height: size.h,
        color: appColors.glassBase.withValues(alpha: 0.25),
        borderColor: appColors.glassBase.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(50.r),
        gradient: LinearGradient(
          colors: [
            appColors.glassBase.withValues(alpha: 0.30),
            appColors.glassBase.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        child: IconButton(
          alignment: Alignment.center,
          padding: EdgeInsets.zero,
          icon: Icon(icon, color: color, size: iconSize.r),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
