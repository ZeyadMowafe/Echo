import 'package:echo_explorer/core/constants/app_images.dart';
import 'package:echo_explorer/features/onboarding/data/models/onboard_model.dart';
import 'package:echo_explorer/features/onboarding/domain/entities/onboard_entity.dart';

abstract class OnboardingLocalDataSource {
  List<OnboardEntity> getOnboardingData();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  @override
  List<OnboardEntity> getOnboardingData() {
    return [
      OnboardModel(imageBG: AppImages.onboarding.onboardingOne, title: '', description: ''),
      OnboardModel(imageBG: AppImages.onboarding.onboardingTwo, title: '', description: ''),
      OnboardModel(imageBG: AppImages.onboarding.onboardingThree, title: '', description: ''),
    ];
  }
}
