import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/exceptions.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/core/network/network_info.dart';
import 'package:echo_explorer/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:echo_explorer/features/chat/domain/entities/chat_reply_entity.dart';
import 'package:echo_explorer/features/chat/domain/entities/session_entity.dart';
import 'package:echo_explorer/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ChatRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, ChatReplyEntity>> sendMessage({
    required String message,
    required String language,
    String? artifactId,
    String? sessionId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final reply = await remoteDataSource.sendMessage(
          message: message,
          language: language,
          artifactId: artifactId,
          sessionId: sessionId,
        );
        return Right(reply);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message ?? 'Failed to send message', statusCode: e.statusCode));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> getSessions({int limit = 20}) async {
    if (await networkInfo.isConnected) {
      try {
        final sessions = await remoteDataSource.getSessions(limit: limit);
        return Right(sessions);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message ?? 'Failed to get sessions', statusCode: e.statusCode));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, SessionEntity>> getSessionById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final session = await remoteDataSource.getSessionById(id);
        return Right(session);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message ?? 'Failed to get session', statusCode: e.statusCode));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> renameSession(String id, String title) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.renameSession(id, title);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message ?? 'Failed to rename session', statusCode: e.statusCode));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteSession(id);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message ?? 'Failed to delete session', statusCode: e.statusCode));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
