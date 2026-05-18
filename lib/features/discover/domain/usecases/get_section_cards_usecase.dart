import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/core/usecases/usecase.dart';
import 'package:echo_explorer/features/discover/domain/entities/section_card_entity.dart';
import 'package:echo_explorer/features/discover/domain/repositories/discover_repository.dart';

class GetSectionCardsUseCase implements UseCase<List<SectionCardEntity>, NoParams> {
  final DiscoverRepository repository;
  GetSectionCardsUseCase(this.repository);

  @override
  Future<Either<Failure, List<SectionCardEntity>>> call(NoParams params) {
    return repository.getSectionCards();
  }
}
