import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/core/usecases/usecase.dart';
import 'package:echo_explorer/features/chat/domain/repositories/chat_repository.dart';

class RenameSessionParams {
  final String id;
  final String title;
  RenameSessionParams({required this.id, required this.title});
}

class RenameSessionUseCase implements UseCase<void, RenameSessionParams> {
  final ChatRepository repository;
  RenameSessionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RenameSessionParams params) {
    return repository.renameSession(params.id, params.title);
  }
}
