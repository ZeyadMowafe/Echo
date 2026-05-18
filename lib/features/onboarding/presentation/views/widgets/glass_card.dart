import 'dart:ui';
import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:echo_explorer/features/onboarding/data/onboarding_data.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.index, required this.onTapNext});
  final int index;
  final void Function()? onTapNext;

  @override
  Widget build(BuildContext context) {
    final onboardList = OnboardingData.getOnboardData(context);
    final l10n = AppLocalizations.of(context)!;

    return Positioned(
      bottom: 80,
      left: 20,
      right: 20,
      child: CustomGlassContainer(
        color: AppColors.cffffff.withOpacity(0.04),
        borderColor: AppColors.cffffff.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              onboardList[index].title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              onboardList[index].description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 32),
            InkWell(
              onTap: onTapNext,
              borderRadius: BorderRadius.circular(32),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.10)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      index == onboardList.length - 1
                          ? l10n.onboardingGetStarted
                          : l10n.onboardingNext,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Directionality.of(context) == TextDirection.rtl 
                          ? Icons.arrow_back 
                          : Icons.arrow_forward, 
                      color: Colors.white, 
                      size: 20
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