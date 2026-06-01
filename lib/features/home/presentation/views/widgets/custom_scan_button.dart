import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/constants/app_images.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/core/routing/routes.dart';
import 'package:echo_explorer/core/themes/theme_cubit.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class CustomScanButton extends StatelessWidget {
  const CustomScanButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = context.watch<ThemeCubit>().state;

    return InkWell(
      borderRadius: BorderRadius.circular(24.r),
      onTap: () => Navigator.pushNamed(context, AppRoutes.scanView),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          width: 372.w,
          height: 145.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            color: AppColors.of(context).scanButton,
            border: Border.all(
              color: AppColors.cffffff.withOpacity(isDark ? 0.15 : 0.10),
              width: 1,
            ),
          ),
          child: CustomGlassContainer(
            color: Colors.transparent,

            sigmaX: 2,
            sigmaY: 2,
            borderColor: Colors.transparent,
            gradient: LinearGradient(
              colors: [
                AppColors.cffffff.withOpacity(isDark ? 0.30 : 0.08),
                AppColors.cffffff.withOpacity(isDark ? 0.05 : 0.02),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24.r),
            padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 18.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10.w,
              children: [
                SvgPicture.asset(
                  AppImages.scan,
                  width: ScreenUtils.icon2Xl,
                  height: ScreenUtils.icon2Xl,
                  colorFilter: ColorFilter.mode(
                    AppColors.cffffff,
                    BlendMode.srcIn,
                  ),
                ),

                Gap(4.w),
                Flexible(
                  child: Text(
                    l10n.homeScanButton,
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: AppColors.cffffff,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Gap(4.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.cf9f9f9,
                  size: ScreenUtils.iconXl,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
