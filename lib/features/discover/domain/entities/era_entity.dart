class EraEntity {
  final String title, description;
  final String? imagePath;
  final bool isRightAligned;
  EraEntity({required this.title, required this.description, this.imagePath, this.isRightAligned = false});
}
