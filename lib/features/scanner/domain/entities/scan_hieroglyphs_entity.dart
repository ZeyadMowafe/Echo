class ScanHieroglyphsEntity {
  final bool detected;
  final String? translation;
  final String? translationMethod;
  final int? totalLines;
  final int? totalGlyphs;
  final int? cartoucheCount;
  final List<String>? royalNames;

  ScanHieroglyphsEntity({
    required this.detected,
    this.translation,
    this.translationMethod,
    this.totalLines,
    this.totalGlyphs,
    this.cartoucheCount,
    this.royalNames,
  });
}
