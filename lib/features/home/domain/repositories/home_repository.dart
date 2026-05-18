import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/features/home/domain/entities/slider_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<SliderEntity>>> getSliders();
}
