import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/core/usecases/usecase.dart';
import 'package:echo_explorer/features/chat/domain/entities/chat_reply_entity.dart';
import 'package:echo_explorer/features/chat/domain/repositories/chat_repository.dart';

class SendMessageParams {
  final String message;
  final String language;
  final String? artifactId;
  final String? sessionId;
  SendMessageParams({required this.message, this.language = 'en', this.artifactId, this.sessionId});
}

class SendMessageUseCase implements UseCase<ChatReplyEntity, SendMessageParams> {
  final ChatRepository repository;
  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, ChatReplyEntity>> call(SendMessageParams params) {
    return repository.sendMessage(
      message: params.message,
      language: params.language,
      artifactId: params.artifactId,
      sessionId: params.sessionId,
    );
  }
}
