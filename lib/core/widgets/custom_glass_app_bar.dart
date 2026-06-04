import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/widgets/custom_glass_back_button.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomGlassAppBar extends StatelessWidget {
  const CustomGlassAppBar({
    super.key,
    required this.title,
    this.previousState = '',
    this.onPressed,
    this.leading,
    this.trailing,
    this.subtitle,
    this.rtlAware = false,
    this.trailingBuilder,
    this.barColor,
    this.barBorderColor,
    this.textColor,
    this.iconColor,
  });

  final String title;
  final String? subtitle;
  final String previousState;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Widget? trailing;
  final bool rtlAware;
  final Widget Function(BuildContext)? trailingBuilder;
  final Color? barColor;
  final Color? barBorderColor;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final glassColor = barColor ?? AppColors.of(context).discoverAppBar;
    final glassBorder = barBorderColor ?? glassColor.withValues(alpha: 0.05);
    final headingColor = textColor ?? AppColors.of(context).footer;

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
      borderColor: glassBorder,
      padding: EdgeInsets.only(top: 6.h, bottom: 6.h, left: 20.w, right: 20.w),
      child: SafeArea(
        bottom: false,
        child: Row(
          spacing: 8.w,
          children: [
            if (leading != null)
              leading!
            else if (onPressed != null)
              CustomGlassBackButton(
                onPressed: onPressed,
                rtlAware: rtlAware,
                iconColor: iconColor,
              ),
            if (subtitle == null)
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: headingColor,
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
                        color: headingColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: headingColor.withValues(alpha: 0.8),
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
