import 'dart:ui';
import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CustomGlassDrawer extends StatelessWidget {
  const CustomGlassDrawer({
    super.key,
    required this.currentFeature,
    required this.onTap,
  });
  final String currentFeature;
  final Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      backgroundColor: Colors.transparent,
      width: 0.7.sw,
      child: CustomGlassContainer(
        color: AppColors.cffffff.withOpacity(0.10),
        gradient: LinearGradient(
          colors: [
            AppColors.cffffff.withOpacity(0.20),
            AppColors.cffffff.withOpacity(0.05),
          ],
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
        ),
        borderColor: AppColors.cffffff.withOpacity(0.10),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(ScreenUtils.sm),
                child: CustomGlassContainer(
                  width: ScreenUtils.glassButtonSize,
                  height: ScreenUtils.glassButtonSize,
                  borderRadius: BorderRadius.circular(ScreenUtils.radiusFull),
                  borderColor: AppColors.cffffff.withOpacity(0.10),
                  color: AppColors.cffffff.withOpacity(0.10),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.cffffff.withOpacity(0.20),
                      AppColors.cffffff.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  child: CustomGlassContainer(
                    width: ScreenUtils.glassButtonSize,
                    height: ScreenUtils.glassButtonSize,
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
                    child: IconButton(
                      alignment: Alignment.center,
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Directionality.of(context) == TextDirection.rtl
                            ? Icons.arrow_forward_rounded
                            : Icons.arrow_back_rounded,
                        color: AppColors.cf9f9f9,
                        size: ScreenUtils.iconMd,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
              Gap(20.h),
              _buildDrawerItem(
                featureKey: AppStrings.homeFeature.key,
                icon: currentFeature == AppStrings.homeFeature.key
                    ? Icons.home
                    : Icons.home_outlined,
                title: l10n.drawerHome,
                isSelected: currentFeature == AppStrings.homeFeature.key,
              ),
              _buildDrawerItem(
                featureKey: AppStrings.discoverFeature.key,
                icon: currentFeature == AppStrings.discoverFeature.key
                    ? Icons.star
                    : Icons.star_border,
                title: l10n.drawerDiscover,
                isSelected: currentFeature == AppStrings.discoverFeature.key,
              ),
              _buildDrawerItem(
                featureKey: AppStrings.scanFeature.key,
                icon: currentFeature == AppStrings.scanFeature.key
                    ? Icons.crop_free
                    : Icons.crop_free,
                title: l10n.drawerScan,
                isSelected: currentFeature == AppStrings.scanFeature.key,
              ),
              _buildDrawerItem(
                featureKey: AppStrings.chatFeature.key,
                icon: currentFeature == AppStrings.chatFeature.key
                    ? Icons.chat
                    : Icons.chat_outlined,
                title: l10n.drawerChat,
                isSelected: currentFeature == AppStrings.chatFeature.key,
              ),
              _buildDrawerItem(
                featureKey: AppStrings.profileFeature.key,
                icon: currentFeature == AppStrings.profileFeature.key
                    ? Icons.person
                    : Icons.person_outline,
                title: l10n.drawerProfile,
                isSelected: currentFeature == AppStrings.profileFeature.key,
              ),
              const Spacer(),
              Divider(
                color: AppColors.cffffff.withOpacity(.5),
                thickness: 1,
                indent: 14.w,
                endIndent: 14.w,
              ),
              _buildDrawerItem(
                featureKey: AppStrings.settingsFeature.key,
                icon: Icons.settings_outlined,
                title: l10n.drawerSettings,
                isSelected: currentFeature == AppStrings.settingsFeature.key,
              ),
              Gap(6.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required String featureKey,
    required IconData icon,
    required String title,
    required bool isSelected,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(ScreenUtils.xl),
      onTap: () => onTap(featureKey),
      child: CustomGlassContainer(
        color: isSelected ? AppColors.cffffff.withOpacity(0.10) : null,
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  AppColors.cffffff.withOpacity(0.10),
                  AppColors.cffffff.withOpacity(0.10),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : null,
        padding: EdgeInsets.symmetric(horizontal: 36.w, vertical: 13.h),
        margin: EdgeInsets.symmetric(vertical: 4.h),
        borderRadius: isSelected ? BorderRadius.circular(ScreenUtils.xl) : null,
        borderColor: isSelected ? AppColors.cffffff.withOpacity(0.10) : null,
        child: Row(
          spacing: 14.w,
          children: [
            Icon(icon, color: AppColors.cf9f9f9, size: ScreenUtils.iconMd),
            Text(
              title,
              style: TextStyle(
                color: AppColors.cffffff,
                fontSize: 16.sp,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}