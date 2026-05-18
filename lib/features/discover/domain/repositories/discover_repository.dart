import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/features/discover/domain/entities/god_entity.dart';
import 'package:echo_explorer/features/discover/domain/entities/era_entity.dart';
import 'package:echo_explorer/features/discover/domain/entities/section_card_entity.dart';

abstract class DiscoverRepository {
  Future<Either<Failure, List<GodEntity>>> getGods();
  Future<Either<Failure, List<EraEntity>>> getEras();
  Future<Either<Failure, List<SectionCardEntity>>> getSectionCards();
}
