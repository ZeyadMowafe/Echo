import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/core/usecases/usecase.dart';
import 'package:echo_explorer/features/chat/domain/entities/session_entity.dart';
import 'package:echo_explorer/features/chat/domain/repositories/chat_repository.dart';

class GetSessionByIdUseCase implements UseCase<SessionEntity, String> {
  final ChatRepository repository;
  GetSessionByIdUseCase(this.repository);

  @override
  Future<Either<Failure, SessionEntity>> call(String params) {
    return repository.getSessionById(params);
  }
}
