import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/features/chat/domain/entities/chat_reply_entity.dart';
import 'package:echo_explorer/features/chat/domain/entities/session_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, ChatReplyEntity>> sendMessage({
    required String message,
    required String language,
    String? artifactId,
    String? sessionId,
  });
  Future<Either<Failure, List<SessionEntity>>> getSessions({int limit = 20});
  Future<Either<Failure, SessionEntity>> getSessionById(String id);
  Future<Either<Failure, void>> renameSession(String id, String title);
  Future<Either<Failure, void>> deleteSession(String id);
}
