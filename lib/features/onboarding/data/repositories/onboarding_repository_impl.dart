import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:echo_explorer/features/onboarding/domain/entities/onboard_entity.dart';
import 'package:echo_explorer/features/onboarding/domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;

  OnboardingRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<OnboardEntity>>> getOnboardingData() async {
    try {
      final data = localDataSource.getOnboardingData();
      return Right(data);
    } catch (e) {
      return Left(CacheFailure('Failed to load onboarding data'));
    }
  }
}
