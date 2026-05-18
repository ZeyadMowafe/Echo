import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/features/scanner/domain/entities/scan_log_entity.dart';
import 'package:echo_explorer/features/scanner/domain/entities/scan_response_entity.dart';

abstract class ScanRepository {
  Future<Either<Failure, ScanResponseEntity>> analyzeImage({required String imagePath, required String language});
  Future<Either<Failure, List<ScanLogEntity>>> getScanLogs({int page = 1, int pageSize = 20});
  Future<Either<Failure, List<ScanLogEntity>>> getFavoriteScans({int page = 1, int pageSize = 20});
  Future<Either<Failure, void>> toggleFavorite(String scanLogId);
}
