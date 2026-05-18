import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/features/discover/data/datasources/discover_local_data_source.dart';
import 'package:echo_explorer/features/discover/domain/entities/god_entity.dart';
import 'package:echo_explorer/features/discover/domain/entities/era_entity.dart';
import 'package:echo_explorer/features/discover/domain/entities/section_card_entity.dart';
import 'package:echo_explorer/features/discover/domain/repositories/discover_repository.dart';

class DiscoverRepositoryImpl implements DiscoverRepository {
  final DiscoverLocalDataSource localDataSource;

  DiscoverRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<GodEntity>>> getGods() async {
    try {
      final gods = localDataSource.getGods();
      return Right(gods);
    } catch (e) {
      return Left(CacheFailure('Failed to load gods'));
    }
  }

  @override
  Future<Either<Failure, List<EraEntity>>> getEras() async {
    try {
      final eras = localDataSource.getEras();
      return Right(eras);
    } catch (e) {
      return Left(CacheFailure('Failed to load eras'));
    }
  }

  @override
  Future<Either<Failure, List<SectionCardEntity>>> getSectionCards() async {
    try {
      final cards = localDataSource.getSectionCards();
      return Right(cards);
    } catch (e) {
      return Left(CacheFailure('Failed to load section cards'));
    }
  }
}
