import 'dart:ui';
import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:echo_explorer/features/onboarding/data/onboarding_data.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.index, required this.onTapNext});
  final int index;
  final void Function()? onTapNext;

  @override
  Widget build(BuildContext context) {
    final onboardList = OnboardingData.getOnboardData(context);
    final l10n = AppLocalizations.of(context)!;

    return Positioned(
      bottom: 80.h,
      left: 20.w,
      right: 20.w,
      child: CustomGlassContainer(
        color: AppColors.cffffff.withOpacity(0.04),
        borderColor: AppColors.cffffff.withOpacity(0.04),
        borderRadius: BorderRadius.circular(ScreenUtils.glassBorderRadius),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              onboardList[index].title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(12.h),
            Text(
              onboardList[index].description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
            Gap(ScreenUtils.xl),
            InkWell(
              onTap: onTapNext,
              borderRadius: BorderRadius.circular(ScreenUtils.xl),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 60.w,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(ScreenUtils.xl),
                  border: Border.all(color: Colors.white.withOpacity(0.10)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      index == onboardList.length - 1
                          ? l10n.onboardingGetStarted
                          : l10n.onboardingNext,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Gap(ScreenUtils.sm),
                    Icon(
                      Directionality.of(context) == TextDirection.rtl 
                          ? Icons.arrow_back 
                          : Icons.arrow_forward, 
                      color: Colors.white, 
                      size: 20.r
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}