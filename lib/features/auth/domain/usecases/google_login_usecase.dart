import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/core/usecases/usecase.dart';
import 'package:echo_explorer/features/auth/domain/entities/user_entity.dart';
import 'package:echo_explorer/features/auth/domain/repositories/auth_repository.dart';

class GoogleLoginParams {
  final String idToken;
  GoogleLoginParams({required this.idToken});
}

class GoogleLoginUseCase implements UseCase<UserEntity, GoogleLoginParams> {
  final AuthRepository repository;
  GoogleLoginUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(GoogleLoginParams params) {
    return repository.googleLogin(idToken: params.idToken);
  }
}