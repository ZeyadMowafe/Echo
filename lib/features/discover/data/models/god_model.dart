import 'package:echo_explorer/features/discover/domain/entities/god_entity.dart';

class GodModel extends GodEntity {
  GodModel({
    required super.title,
    super.subtitle,
    required super.description,
    required super.coverImagePath,
    required super.bgImagePath,
  });
}