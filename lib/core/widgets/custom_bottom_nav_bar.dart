import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottomNavBar extends StatelessWidget {
  final String currentFeature;
  final Function(String) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentFeature,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    return CustomGlassContainer(
      borderColor: appColors.glassBase.withValues(alpha: 0.04),
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(ScreenUtils.glassBorderRadius),
      ),
      color: appColors.glassBase.withValues(alpha: 0.25),
      gradient: LinearGradient(
        colors: [
          appColors.glassBase.withValues(alpha: 0.30),
          appColors.glassBase.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      child: CustomGlassContainer(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ScreenUtils.glassBorderRadius),
        ),
        color: appColors.bottomNavBar.withValues(alpha: 0.35),
        borderColor: appColors.glassBase.withValues(alpha: 0.50),
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 2),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: ScreenUtils.navBarHeight,
            child: Row(
              children: [
                _buildNavItem(
                  context,
                  icon: currentFeature == AppStrings.homeFeature.key
                      ? Icons.home
                      : Icons.home_outlined,
                  featureKey: AppStrings.homeFeature.key,
                ),
                const Spacer(flex: 1),
                _buildNavItem(
                  context,
                  icon: currentFeature == AppStrings.discoverFeature.key
                      ? Icons.star
                      : Icons.star_border,
                  featureKey: AppStrings.discoverFeature.key,
                ),
                const Spacer(flex: 3),
                _buildNavItem(
                  context,
                  icon: currentFeature == AppStrings.chatFeature.key
                      ? Icons.chat
                      : Icons.chat_outlined,
                  featureKey: AppStrings.chatFeature.key,
                ),
                const Spacer(flex: 1),
                _buildNavItem(
                  context,
                  icon: currentFeature == AppStrings.profileFeature.key
                      ? Icons.person
                      : Icons.person_outline,
                  featureKey: AppStrings.profileFeature.key,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String featureKey,
  }) {
    return IconButton(
          icon: Icon(
            icon,
            color: AppColors.of(context).icons,
            size: ScreenUtils.iconMd,
          ),
      onPressed: () => onTap(featureKey),
    );
  }
}