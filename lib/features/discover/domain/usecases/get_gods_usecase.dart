import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/core/usecases/usecase.dart';
import 'package:echo_explorer/features/discover/domain/entities/god_entity.dart';
import 'package:echo_explorer/features/discover/domain/repositories/discover_repository.dart';

class GetGodsUseCase implements UseCase<List<GodEntity>, NoParams> {
  final DiscoverRepository repository;
  GetGodsUseCase(this.repository);

  @override
  Future<Either<Failure, List<GodEntity>>> call(NoParams params) {
    return repository.getGods();
  }
}
