import 'package:echo_explorer/core/constants/app_images.dart';
import 'package:echo_explorer/features/home/data/models/slider_model.dart';
import 'package:echo_explorer/features/home/domain/entities/slider_entity.dart';

abstract class HomeLocalDataSource {
  List<SliderEntity> getSliders();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  @override
  List<SliderEntity> getSliders() {
    return [
      SliderModel(imagePath: AppImages.homeSlider.homeSliderOne, description: ''),
      SliderModel(imagePath: AppImages.homeSlider.homeSliderTwo, description: ''),
    ];
  }
}
