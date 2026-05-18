import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/features/onboarding/domain/entities/onboard_entity.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, List<OnboardEntity>>> getOnboardingData();
}
