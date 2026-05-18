import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:flutter/material.dart';

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
    return CustomGlassContainer(
      borderColor: AppColors.cffffff.withOpacity(0.04),
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      color: AppColors.cffffff.withOpacity(0.25),
      gradient: LinearGradient(
        colors: [
          AppColors.cffffff.withOpacity(0.30),
          AppColors.cffffff.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),

      child: CustomGlassContainer(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        color: AppColors.of(context).bottomNavBar.withOpacity(0.35),
        borderColor: AppColors.c162410.withOpacity(0.50),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 2),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 40,
            child: Row(
              children: [
                _buildNavItem(context, icon: currentFeature==AppStrings.homeFeature.key?Icons.home:Icons.home_outlined, featureKey: AppStrings.homeFeature.key,),
                const Spacer(flex: 1),
                _buildNavItem(context, icon: currentFeature==AppStrings.discoverFeature.key?Icons.star:Icons.star_border, featureKey: AppStrings.discoverFeature.key, ),
                const Spacer(flex: 3),
                _buildNavItem(context, icon: currentFeature==AppStrings.chatFeature.key?Icons.chat:Icons.chat_outlined, featureKey: AppStrings.chatFeature.key, ),
                const Spacer(flex: 1),
                _buildNavItem(context, icon: currentFeature==AppStrings.profileFeature.key?Icons.person:Icons.person_outline, featureKey: AppStrings.profileFeature.key, ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required String featureKey}) {
    return IconButton(
      icon: Icon(
        icon,
        color: AppColors.of(context).icons,
        size: 24,
      ),
      onPressed: () => onTap(featureKey),
    );
  }
}