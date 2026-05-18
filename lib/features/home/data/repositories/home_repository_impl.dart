import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/features/home/data/datasources/home_local_data_source.dart';
import 'package:echo_explorer/features/home/domain/entities/slider_entity.dart';
import 'package:echo_explorer/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource localDataSource;

  HomeRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<SliderEntity>>> getSliders() async {
    try {
      final sliders = localDataSource.getSliders();
      return Right(sliders);
    } catch (e) {
      return Left(CacheFailure('Failed to load sliders'));
    }
  }
}
