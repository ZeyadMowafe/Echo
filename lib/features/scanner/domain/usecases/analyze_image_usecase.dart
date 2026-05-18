import 'package:dartz/dartz.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/core/usecases/usecase.dart';
import 'package:echo_explorer/features/scanner/domain/entities/scan_response_entity.dart';
import 'package:echo_explorer/features/scanner/domain/repositories/scan_repository.dart';

class AnalyzeImageUseCase implements UseCase<ScanResponseEntity, AnalyzeImageParams> {
  final ScanRepository repository;
  AnalyzeImageUseCase(this.repository);

  @override
  Future<Either<Failure, ScanResponseEntity>> call(AnalyzeImageParams params) {
    return repository.analyzeImage(imagePath: params.imagePath, language: params.language);
  }
}

class AnalyzeImageParams {
  final String imagePath;
  final String language;
  AnalyzeImageParams({required this.imagePath, required this.language});
}
