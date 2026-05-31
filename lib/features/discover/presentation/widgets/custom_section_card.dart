import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:echo_explorer/features/discover/data/models/section_card_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CustomSectionCard extends StatelessWidget {
  const CustomSectionCard({
    super.key,
    required this.sectionCardModel,
    required this.onPressed,
  });

  final SectionCardModel sectionCardModel;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 22.w, right: 22.w, bottom: 26.h),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtils.glassBorderRadius),
        image: DecorationImage(
          image: AssetImage(sectionCardModel.image),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            AppColors.c000000.withOpacity(0.1),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            sectionCardModel.title,
            style: TextStyle(
              color: AppColors.cffffff,
              fontSize: 32.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          CustomGlassContainer(
            color: AppColors.cffffff.withOpacity(.10),
            height: 50.h,
            borderRadius: BorderRadius.circular(ScreenUtils.xl),
            borderColor: AppColors.cffffff.withOpacity(.10),
            gradient: LinearGradient(
              colors: [
                AppColors.cffffff.withOpacity(.10),
                AppColors.cffffff.withOpacity(.10)
              ],
              begin: AlignmentGeometry.topCenter,
              end: AlignmentGeometry.bottomCenter,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cffffff.withOpacity(0.01),
              ),
              onPressed: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    sectionCardModel.buttonText,
                    style: TextStyle(
                      color: AppColors.cffffff,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Gap(4.w),
                  Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.arrow_back
                        : Icons.arrow_forward,
                    size: 20.r,
                    color: AppColors.cf9f9f9,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
