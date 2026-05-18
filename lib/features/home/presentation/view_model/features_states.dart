import 'package:echo_explorer/core/constants/app_strings.dart';

abstract class FeaturesStates {
  final String featureName;
  const FeaturesStates({required this.featureName}); 
}

class FeaturesInitialState extends FeaturesStates {
  FeaturesInitialState() : super(featureName: AppStrings.homeFeature.key);
}

class FeatureChangedState extends FeaturesStates {
  FeatureChangedState({required super.featureName});
}