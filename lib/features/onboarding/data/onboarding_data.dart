import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:echo_explorer/core/constants/app_images.dart';
import 'package:echo_explorer/features/onboarding/data/models/onboard_model.dart';

class OnboardingData {
  static List<OnboardModel> getOnboardData(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return [
      OnboardModel(
        imageBG: AppImages.onboarding.onboardingOne,
        title: l10n.onboardingTitleOne,
        description: l10n.onboardingDescOne,
      ),
      OnboardModel(
        imageBG: AppImages.onboarding.onboardingTwo,
        title: l10n.onboardingTitleTwo,
        description: l10n.onboardingDescTwo,
      ),
      OnboardModel(
        imageBG: AppImages.onboarding.onboardingThree,
        title: l10n.onboardingTitleThree,
        description: l10n.onboardingDescThree,
      ),
    ];
  }
}