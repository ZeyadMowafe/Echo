class ScanArtifactEntity {
  final bool isPrimaryModel;
  final String? artifactModelId;
  final String? name;
  final String? description;
  final String? era;
  final String? material;
  final String? category;
  final String? type;
  final String? imageUrl;

  ScanArtifactEntity({
    required this.isPrimaryModel,
    this.artifactModelId,
    this.name,
    this.description,
    this.era,
    this.material,
    this.category,
    this.type,
    this.imageUrl,
  });
}
