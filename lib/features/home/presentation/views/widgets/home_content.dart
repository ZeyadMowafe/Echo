import 'package:echo_explorer/core/constants/app_images.dart';
import 'package:echo_explorer/core/routing/routes.dart';
import 'package:echo_explorer/core/widgets/custom_section_button.dart';
import 'package:echo_explorer/features/home/presentation/views/widgets/custom_home_app_bar.dart';
import 'package:echo_explorer/features/home/presentation/views/widgets/custom_home_slider.dart';
import 'package:echo_explorer/features/home/presentation/views/widgets/custom_scan_button.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(left: 9.w, right: 9.w, bottom: 13.h),
      child: Column(
        spacing: 13.h,
        children: [
          const CustomHomeAppBar(),
          const CustomHomeSlider(),
          const CustomScanButton(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 15.w,
              children: [
                CustomSectionButton(
                  image: AppImages.egyptianHistory.egyptionHistoryCover,
                  title: l10n.homeHistoryTitle,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.egyptianHistoryView);
                  },
                ),
                CustomSectionButton(
                  image: AppImages.mythology.mythologyCover,
                  title: l10n.homeMythologyTitle,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.mythologyView);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}