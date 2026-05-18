import 'package:echo_explorer/features/scanner/domain/entities/scan_artifact_entity.dart';

class ScanArtifactModel extends ScanArtifactEntity {
  ScanArtifactModel({
    required super.isPrimaryModel,
    super.artifactModelId,
    super.name,
    super.description,
    super.era,
    super.material,
    super.category,
    super.type,
    super.imageUrl,
  });

  factory ScanArtifactModel.fromJson(Map<String, dynamic> json) {
    return ScanArtifactModel(
      isPrimaryModel: json['isPrimaryModel'] ?? false,
      artifactModelId: json['artifactModelId'],
      name: json['name'],
      description: json['description'],
      era: json['era'],
      material: json['material'],
      category: json['category'],
      type: json['type'],
      imageUrl: json['imageUrl'],
    );
  }
}
