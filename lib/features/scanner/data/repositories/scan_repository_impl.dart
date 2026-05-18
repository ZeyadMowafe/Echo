import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/exceptions.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/core/network/network_info.dart';
import 'package:echo_explorer/features/scanner/data/datasources/scan_remote_data_source.dart';
import 'package:echo_explorer/features/scanner/domain/entities/scan_log_entity.dart';
import 'package:echo_explorer/features/scanner/domain/entities/scan_response_entity.dart';
import 'package:echo_explorer/features/scanner/domain/repositories/scan_repository.dart';

class ScanRepositoryImpl implements ScanRepository {
  final ScanRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ScanRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, ScanResponseEntity>> analyzeImage({required String imagePath, required String language}) async {
    if (!await networkInfo.isConnected) return Left(NetworkFailure());
    try {
      final model = await remoteDataSource.analyzeImage(imagePath: imagePath, language: language);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error', statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, List<ScanLogEntity>>> getScanLogs({int page = 1, int pageSize = 20}) async {
    if (!await networkInfo.isConnected) return Left(NetworkFailure());
    try {
      final models = await remoteDataSource.getScanLogs(page: page, pageSize: pageSize);
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error', statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, List<ScanLogEntity>>> getFavoriteScans({int page = 1, int pageSize = 20}) async {
    if (!await networkInfo.isConnected) return Left(NetworkFailure());
    try {
      final models = await remoteDataSource.getFavoriteScans(page: page, pageSize: pageSize);
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error', statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(String scanLogId) async {
    if (!await networkInfo.isConnected) return Left(NetworkFailure());
    try {
      await remoteDataSource.toggleFavorite(scanLogId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error', statusCode: e.statusCode));
    }
  }
}
