import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/exceptions.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/core/network/network_info.dart';
import 'package:echo_explorer/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:echo_explorer/features/profile/domain/entities/profile_entity.dart';
import 'package:echo_explorer/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    if (await networkInfo.isConnected) {
      try {
        final profile = await remoteDataSource.getProfile();
        return Right(profile);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message ?? 'Failed to get profile'));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile({required String name, required String email, required String lang}) async {
    if (await networkInfo.isConnected) {
      try {
        final profile = await remoteDataSource.updateProfile(name: name, email: email, lang: lang);
        return Right(profile);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message ?? 'Failed to update profile'));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
