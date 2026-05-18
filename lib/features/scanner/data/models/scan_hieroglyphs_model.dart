import 'package:echo_explorer/features/scanner/domain/entities/scan_hieroglyphs_entity.dart';

class ScanHieroglyphsModel extends ScanHieroglyphsEntity {
  ScanHieroglyphsModel({
    required super.detected,
    super.translation,
    super.translationMethod,
    super.totalLines,
    super.totalGlyphs,
    super.cartoucheCount,
    super.royalNames,
  });

  factory ScanHieroglyphsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ScanHieroglyphsModel(detected: false);
    }
    final stats = json['stats'] as Map<String, dynamic>?;
    return ScanHieroglyphsModel(
      detected: json['detected'] ?? false,
      translation: json['translation'],
      translationMethod: json['translationMethod'],
      totalLines: stats?['totalLines'],
      totalGlyphs: stats?['totalGlyphs'],
      cartoucheCount: stats?['cartoucheCount'],
      royalNames: stats?['royalNames'] != null ? List<String>.from(stats!['royalNames']) : null,
    );
  }
}
