import 'package:echo_explorer/features/scanner/domain/entities/scan_artifact_entity.dart';
import 'package:echo_explorer/features/scanner/domain/entities/scan_hieroglyphs_entity.dart';

class ScanResponseEntity {
  final String status;
  final int processingTimeMs;
  final ScanArtifactEntity artifact;
  final ScanHieroglyphsEntity? hieroglyphs;
  final String? scanLogId;

  ScanResponseEntity({
    required this.status,
    required this.processingTimeMs,
    required this.artifact,
    this.hieroglyphs,
    this.scanLogId,
  });
}
