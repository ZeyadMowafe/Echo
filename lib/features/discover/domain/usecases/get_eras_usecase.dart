import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/core/usecases/usecase.dart';
import 'package:echo_explorer/features/discover/domain/entities/era_entity.dart';
import 'package:echo_explorer/features/discover/domain/repositories/discover_repository.dart';

class GetErasUseCase implements UseCase<List<EraEntity>, NoParams> {
  final DiscoverRepository repository;
  GetErasUseCase(this.repository);

  @override
  Future<Either<Failure, List<EraEntity>>> call(NoParams params) {
    return repository.getEras();
  }
}
