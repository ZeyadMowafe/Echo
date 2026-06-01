import 'package:echo_explorer/features/scanner/domain/entities/scan_response_entity.dart';

class ScanResultArgs {
  final ScanResponseEntity result;
  final String? imagePath;
  final bool isFavorited;
  ScanResultArgs({
    required this.result,
    this.imagePath,
    this.isFavorited = false,
  });
}
