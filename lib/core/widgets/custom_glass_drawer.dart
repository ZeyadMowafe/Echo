import 'dart:ui';
import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

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
      width: MediaQuery.of(context).size.width * 0.7,
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
              CustomGlassContainer(
                width: 34,
                height: 34,
                borderRadius: BorderRadius.circular(50),
                borderColor: AppColors.cffffff.withOpacity(0.10),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  width: 34,
                  height: 34,
                  color: AppColors.cffffff.withOpacity(0.25),
                  borderColor: AppColors.cffffff.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(50),
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
                      size: 22,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              const SizedBox(height: 20),

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
                isSelected: currentFeature == AppStrings.discoverFeature.key
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
                indent: 14,
                endIndent: 14,
              ),
              _buildDrawerItem(
                featureKey: AppStrings.settingsFeature.key,
                icon: Icons.settings_outlined,
                title: l10n.drawerSettings, 
                isSelected: currentFeature == AppStrings.settingsFeature.key,
              ),
              const SizedBox(height: 6),
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
      borderRadius: BorderRadius.circular(32),
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
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 13),
        margin: const EdgeInsets.symmetric(vertical: 4),
        borderRadius: isSelected ? BorderRadius.circular(32) : null,
        borderColor: isSelected ? AppColors.cffffff.withOpacity(0.10) : null,
        child: Row(
          spacing: 14,
          children: [
            Icon(icon, color: AppColors.cf9f9f9, size: 22),
            Text(
              title,
              style: TextStyle(
                color: AppColors.cffffff,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}