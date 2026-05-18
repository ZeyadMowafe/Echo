import 'package:echo_explorer/features/discover/domain/entities/era_entity.dart';

class EraModel extends EraEntity {
  EraModel({
    required super.title,
    required super.description,
    super.imagePath,
    super.isRightAligned = false,
  });
}