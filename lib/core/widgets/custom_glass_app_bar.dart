import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/widgets/custom_glass_back_button.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomGlassAppBar extends StatelessWidget {
  const CustomGlassAppBar({
    super.key,
    required this.previousState,
    required this.title,
    required this.onPressed,
    this.trailing,
    this.subtitle,
    this.rtlAware = false,
    this.trailingBuilder,
    this.barColor,
    this.barBorderColor,
  });

  final String title;
  final String? subtitle;
  final String previousState;
  final VoidCallback onPressed;
  final Widget? trailing;
  final bool rtlAware;
  final Widget Function(BuildContext)? trailingBuilder;
  final Color? barColor;
  final Color? barBorderColor;

  @override
  Widget build(BuildContext context) {
    final glassColor = barColor ?? AppColors.of(context).discoverAppBar;
    final glassBorder = barBorderColor ?? AppColors.c162410;
    return CustomGlassContainer(
      color: glassColor.withValues(alpha: 0.25),
      gradient: LinearGradient(
        colors: [
          glassColor.withValues(alpha: 0.30),
          glassColor.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderColor: glassBorder.withValues(alpha: 0.50),
      padding: EdgeInsets.only(top: 6.h, bottom: 6.h, left: 20.w, right: 20.w),
      child: SafeArea(
        bottom: false,
        child: Row(
          spacing: 8.w,
          children: [
            CustomGlassBackButton(
              onPressed: onPressed,
              rtlAware: rtlAware,
            ),
            if (subtitle == null)
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.of(context).footer,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.of(context).footer,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: AppColors.of(context).footer.withValues(alpha: 0.8),
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            if (trailingBuilder != null)
              Builder(builder: (ctx) => trailingBuilder!(ctx))
            else if (trailing != null)
              trailing!,
          ],
        ),
      ),
    );
  }
}
