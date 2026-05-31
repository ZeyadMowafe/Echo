import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CustomSectionButton extends StatelessWidget {
  const CustomSectionButton({
    super.key,
    required this.onTap,
    required this.image,
    required this.title,
  });

  final Function() onTap;
  final String image;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 224.h,
      width: 170.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtils.glassBorderRadius),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.fill,
          colorFilter: ColorFilter.mode(
            AppColors.c000000.withOpacity(0.15),
            BlendMode.darken,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(ScreenUtils.glassBorderRadius),
          onTap: onTap,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              PositionedDirectional(
                bottom: 17.h,
                end: 6.w,
                start: 12.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          height: 1.2,
                          color: AppColors.cffffff,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Gap(ScreenUtils.sm),
                    CustomGlassContainer(
                      width: ScreenUtils.iconLg,
                      height: ScreenUtils.iconLg,
                      color: AppColors.cffffff.withOpacity(0.25),
                      borderColor: AppColors.cffffff.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(ScreenUtils.radiusFull),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.cffffff.withOpacity(0.30),
                          AppColors.cffffff.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      child: Icon(
                        Directionality.of(context) == TextDirection.rtl
                            ? Icons.arrow_back_rounded
                            : Icons.arrow_forward_rounded,
                        color: AppColors.cf9f9f9,
                        size: ScreenUtils.iconSm,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}