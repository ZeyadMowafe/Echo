import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/core/routing/routes.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomScanButton extends StatelessWidget {
  const CustomScanButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      borderRadius: BorderRadius.circular(ScreenUtils.glassBorderRadius),
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.scanView);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtils.glassBorderRadius),
          color: AppColors.of(context).scanButton,
        ),
        child: CustomGlassContainer(
          color: AppColors.cffffff.withOpacity(0.30),
          gradient: LinearGradient(
            colors: [
              AppColors.cffffff.withOpacity(0.30),
              AppColors.cffffff.withOpacity(0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(ScreenUtils.glassBorderRadius),
          borderColor: AppColors.cffffff.withOpacity(0.15),
          padding: EdgeInsets.only(top: 42.h, bottom: 42.h, left: 35.w, right: 30.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 14.w,
            children: [
              Icon(
                Icons.crop_free,
                color: AppColors.cf9f9f9,
                size: ScreenUtils.iconXl,
              ),
              Text(
                l10n.homeScanButton,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.cffffff,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.cf9f9f9,
                size: ScreenUtils.xl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}