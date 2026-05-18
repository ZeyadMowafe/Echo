import 'package:echo_explorer/features/scanner/data/models/scan_artifact_model.dart';
import 'package:echo_explorer/features/scanner/data/models/scan_hieroglyphs_model.dart';
import 'package:echo_explorer/features/scanner/domain/entities/scan_response_entity.dart';

class ScanResponseModel extends ScanResponseEntity {
  ScanResponseModel({
    required super.status,
    required super.processingTimeMs,
    required super.artifact,
    super.hieroglyphs,
    super.scanLogId,
  });

  factory ScanResponseModel.fromJson(Map<String, dynamic> json) {
    return ScanResponseModel(
      status: json['status'] ?? '',
      processingTimeMs: json['processingTimeMs'] ?? 0,
      artifact: ScanArtifactModel.fromJson(json['artifact'] ?? {}),
      hieroglyphs: json['hieroglyphs'] != null
          ? ScanHieroglyphsModel.fromJson(json['hieroglyphs'])
          : null,
      scanLogId: json['scanLogId'],
    );
  }
}
