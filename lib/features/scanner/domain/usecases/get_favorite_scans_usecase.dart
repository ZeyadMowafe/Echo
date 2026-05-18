import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/core/usecases/usecase.dart';
import 'package:echo_explorer/features/scanner/domain/entities/scan_log_entity.dart';
import 'package:echo_explorer/features/scanner/domain/repositories/scan_repository.dart';

class GetFavoriteScansUseCase implements UseCase<List<ScanLogEntity>, FavoriteScansParams> {
  final ScanRepository repository;
  GetFavoriteScansUseCase(this.repository);

  @override
  Future<Either<Failure, List<ScanLogEntity>>> call(FavoriteScansParams params) {
    return repository.getFavoriteScans(page: params.page, pageSize: params.pageSize);
  }
}

class FavoriteScansParams {
  final int page;
  final int pageSize;
  FavoriteScansParams({this.page = 1, this.pageSize = 20});
}
