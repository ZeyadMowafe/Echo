import 'package:echo_explorer/features/scanner/domain/entities/scan_log_entity.dart';

class ScanLogModel extends ScanLogEntity {
  ScanLogModel({
    required super.id,
    super.artifactModelId,
    super.artifactName,
    super.description,
    super.era,
    super.material,
    super.category,
    super.type,
    super.imageUrl,
    super.hieroglyphsTranslation,
    required super.isFavorited,
    super.isPrimaryModel,
    required super.createdAt,
  });

  factory ScanLogModel.fromJson(Map<String, dynamic> json) {
    return ScanLogModel(
      id: json['id'] ?? '',
      artifactModelId: json['artifactModelId'],
      artifactName: json['artifactName'],
      description: json['description'],
      era: json['era'],
      material: json['material'],
      category: json['category'],
      type: json['type'],
      imageUrl: json['imageUrl'],
      hieroglyphsTranslation: json['hieroglyphsTranslation'],
      isFavorited: json['isFavorited'] ?? false,
      isPrimaryModel: json['isPrimaryModel'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
