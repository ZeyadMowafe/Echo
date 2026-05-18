import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/core/usecases/usecase.dart';
import 'package:echo_explorer/features/scanner/domain/entities/scan_log_entity.dart';
import 'package:echo_explorer/features/scanner/domain/repositories/scan_repository.dart';

class GetScanLogsUseCase implements UseCase<List<ScanLogEntity>, ScanLogsParams> {
  final ScanRepository repository;
  GetScanLogsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ScanLogEntity>>> call(ScanLogsParams params) {
    return repository.getScanLogs(page: params.page, pageSize: params.pageSize);
  }
}

class ScanLogsParams {
  final int page;
  final int pageSize;
  ScanLogsParams({this.page = 1, this.pageSize = 20});
}
