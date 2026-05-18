import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/routing/routes.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
class CustomScanButton extends StatelessWidget {
  const CustomScanButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.scanView);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
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
          borderRadius: BorderRadius.circular(24),
          borderColor: AppColors.cffffff.withOpacity(0.15),
          padding: const EdgeInsets.only(top: 42, bottom: 42, left: 35, right: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 14,
            children: [
              Icon(
                Icons.crop_free,
                color: AppColors.cf9f9f9,
                size: 48,
              ),
              Text(
                l10n.homeScanButton, 
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.cffffff,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.cf9f9f9,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}