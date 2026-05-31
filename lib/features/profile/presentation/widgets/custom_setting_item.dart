import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

IconData? _rtlFlipIcon(BuildContext context, IconData? icon) {
  if (icon == null || Directionality.of(context) == TextDirection.ltr) return icon;
  if (icon == Icons.arrow_forward_rounded) return Icons.arrow_back_rounded;
  if (icon == Icons.arrow_forward_ios_rounded) return Icons.arrow_back_ios_rounded;
  if (icon == Icons.arrow_forward) return Icons.arrow_back;
  return icon;
}

class CustomSettingItem extends StatelessWidget {
  final IconData? leadingIcon;
  final String title;
  final bool hasSwitch;
  final bool switchValue;
  final Function(bool)? onSwitchChanged;
  final Function()? onTap;
  final IconData? trailingIcon;

  const CustomSettingItem({
    super.key,
    this.leadingIcon,
    required this.title,
    this.hasSwitch = false,
    this.switchValue = false,
    this.onSwitchChanged,
    this.onTap,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomGlassContainer(
        color: AppColors.of(context).background.withOpacity(0.3),
        borderColor: AppColors.of(context).footer.withOpacity(0.6),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        margin: EdgeInsets.only(bottom: 12.h),
        borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
        height: 56.h,
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                color: AppColors.of(context).footer,
                size: ScreenUtils.iconMd,
              ),
              Gap(10.w),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.of(context).footer,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (hasSwitch)
              SizedBox(
                height: 24.h,
                width: 38.w,
                child: Switch(
                  value: switchValue,
                  onChanged: onSwitchChanged,
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.secondary,
                  inactiveThumbColor: AppColors.secondary,
                  inactiveTrackColor: AppColors.cf9f9f9.withOpacity(0.1),
                ),
              )
            else if (onTap != null && trailingIcon != null) 
              Icon(
                _rtlFlipIcon(context, trailingIcon),
                color: AppColors.of(context).footer,
                size: ScreenUtils.xl,
              ),
          ],
        ),
      ),
    );
  }
}