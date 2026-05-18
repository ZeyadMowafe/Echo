import 'package:echo_explorer/features/home/presentation/cubit/features_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeaturesCubit extends Cubit<FeaturesStates> {
  FeaturesCubit() : super(FeaturesInitialState());

  void changeFeature({required String featureName}) {
    emit(FeatureChangedState(featureName: featureName));
  }
}
