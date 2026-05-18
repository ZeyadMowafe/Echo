import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/core/usecases/usecase.dart';
import 'package:echo_explorer/features/scanner/domain/repositories/scan_repository.dart';

class ToggleFavoriteUseCase implements UseCase<void, String> {
  final ScanRepository repository;
  ToggleFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String scanLogId) {
    return repository.toggleFavorite(scanLogId);
  }
}
