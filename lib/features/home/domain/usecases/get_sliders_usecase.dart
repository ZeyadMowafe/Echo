import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/core/usecases/usecase.dart';
import 'package:echo_explorer/features/home/domain/entities/slider_entity.dart';
import 'package:echo_explorer/features/home/domain/repositories/home_repository.dart';

class GetSlidersUseCase implements UseCase<List<SliderEntity>, NoParams> {
  final HomeRepository repository;
  GetSlidersUseCase(this.repository);

  @override
  Future<Either<Failure, List<SliderEntity>>> call(NoParams params) {
    return repository.getSliders();
  }
}
