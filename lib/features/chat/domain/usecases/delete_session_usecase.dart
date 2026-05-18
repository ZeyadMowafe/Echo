import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/core/usecases/usecase.dart';
import 'package:echo_explorer/features/chat/domain/repositories/chat_repository.dart';

class DeleteSessionUseCase implements UseCase<void, String> {
  final ChatRepository repository;
  DeleteSessionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.deleteSession(params);
  }
}
