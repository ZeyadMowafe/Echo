class ScanLogEntity {
  final String id;
  final String? artifactModelId;
  final String? artifactName;
  final String? description;
  final String? era;
  final String? material;
  final String? category;
  final String? type;
  final String? imageUrl;
  final String? hieroglyphsTranslation;
  final bool isFavorited;
  final DateTime createdAt;

  ScanLogEntity({
    required this.id,
    this.artifactModelId,
    this.artifactName,
    this.description,
    this.era,
    this.material,
    this.category,
    this.type,
    this.imageUrl,
    this.hieroglyphsTranslation,
    required this.isFavorited,
    required this.createdAt,
  });
}
