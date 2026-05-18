import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/core/usecases/usecase.dart';
import 'package:echo_explorer/features/auth/domain/entities/user_entity.dart';
import 'package:echo_explorer/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfileParams {
  final String name;
  final String email;
  final String lang;
  UpdateProfileParams({required this.name, required this.email, this.lang = 'en'});
}

class UpdateProfileUseCase implements UseCase<UserEntity, UpdateProfileParams> {
  final AuthRepository repository;
  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) {
    return repository.updateProfile(
      name: params.name,
      email: params.email,
      lang: params.lang,
    );
  }
}
