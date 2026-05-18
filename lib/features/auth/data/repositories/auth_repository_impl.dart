import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/exceptions.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/core/network/network_info.dart';
import 'package:echo_explorer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:echo_explorer/features/auth/domain/entities/user_entity.dart';
import 'package:echo_explorer/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, UserEntity>> login({required String email, required String password}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.login(email: email, password: password);
        return Right(remoteUser);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message ?? 'Login failed', statusCode: e.statusCode));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({required String email, required String password, required String name}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.register(email: email, password: password, name: name);
        return Right(remoteUser);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message ?? 'Registration failed', statusCode: e.statusCode));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.getProfile();
        return Right(remoteUser);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message ?? 'Failed to get profile', statusCode: e.statusCode));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({required String name, required String email, required String lang}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.updateProfile(name: name, email: email, lang: lang);
        return Right(remoteUser);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message ?? 'Failed to update profile', statusCode: e.statusCode));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
