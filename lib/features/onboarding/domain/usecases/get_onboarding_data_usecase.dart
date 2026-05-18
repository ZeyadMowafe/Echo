import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/core/usecases/usecase.dart';
import 'package:echo_explorer/features/onboarding/domain/entities/onboard_entity.dart';
import 'package:echo_explorer/features/onboarding/domain/repositories/onboarding_repository.dart';

class GetOnboardingDataUseCase implements UseCase<List<OnboardEntity>, NoParams> {
  final OnboardingRepository repository;
  GetOnboardingDataUseCase(this.repository);

  @override
  Future<Either<Failure, List<OnboardEntity>>> call(NoParams params) {
    return repository.getOnboardingData();
  }
}
