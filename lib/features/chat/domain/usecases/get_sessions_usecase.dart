import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/core/usecases/usecase.dart';
import 'package:echo_explorer/features/chat/domain/entities/session_entity.dart';
import 'package:echo_explorer/features/chat/domain/repositories/chat_repository.dart';

class GetSessionsUseCase implements UseCase<List<SessionEntity>, NoParams> {
  final ChatRepository repository;
  GetSessionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<SessionEntity>>> call(NoParams params) {
    return repository.getSessions();
  }
}
