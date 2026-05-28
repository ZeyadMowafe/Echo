import 'dart:convert';
import 'package:echo_explorer/core/hive/cache_helper.dart';
import 'package:echo_explorer/features/scanner/domain/entities/scan_log_entity.dart';
import 'package:echo_explorer/features/scanner/domain/entities/scan_response_entity.dart';
import 'package:echo_explorer/features/scanner/domain/usecases/analyze_image_usecase.dart';
import 'package:echo_explorer/features/scanner/domain/usecases/get_favorite_scans_usecase.dart';
import 'package:echo_explorer/features/scanner/domain/usecases/get_scan_logs_usecase.dart';
import 'package:echo_explorer/features/scanner/domain/usecases/toggle_favorite_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  final AnalyzeImageUseCase analyzeImageUseCase;
  final GetScanLogsUseCase getScanLogsUseCase;
  final GetFavoriteScansUseCase getFavoriteScansUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  String? _currentImagePath;
  String? get currentImagePath => _currentImagePath;

  ScanCubit({
    required this.analyzeImageUseCase,
    required this.getScanLogsUseCase,
    required this.getFavoriteScansUseCase,
    required this.toggleFavoriteUseCase,
  }) : super(ScanInitial());

  void setImagePath(String path) {
    _currentImagePath = path;
    emit(ScanImagePicked(imagePath: path));
  }

  Future<void> analyzeImage() async {
    if (_currentImagePath == null) return;
    if (!isClosed) emit(ScanLoading());
    final lang = CacheHelper.getData(key: 'localeLanguageCode') ?? 'en';
    final result = await analyzeImageUseCase(AnalyzeImageParams(
      imagePath: _currentImagePath!,
      language: lang,
    ));
    if (isClosed) return;
    result.fold(
      (failure) => emit(ScanError(message: failure.message)),
      (response) {
        print('=== AnalyzeImage response: hieroglyphs=${response.hieroglyphs?.translation}, detected=${response.hieroglyphs?.detected} ===');
        final scanLogId = response.scanLogId;
        if (scanLogId != null) {
          CacheHelper.putData(
            key: 'scanData_$scanLogId',
            value: jsonEncode({
              'artifactName': response.artifact.name,
              'description': response.artifact.description,
              'era': response.artifact.era,
              'material': response.artifact.material,
              'category': response.artifact.category,
              'type': response.artifact.type,
              'hieroglyphsTranslation': response.hieroglyphs?.translation,
            }),
          );
        }
        if (!isClosed) emit(ScanResultLoaded(result: response, imagePath: _currentImagePath, isFavorited: false));
      },
    );
  }

  Future<void> loadScanLogs() async {
    emit(ScanLoading());
    final result = await getScanLogsUseCase(ScanLogsParams());
    result.fold(
      (failure) => emit(ScanError(message: failure.message)),
      (logs) => emit(ScanLogsLoaded(scanLogs: logs)),
    );
  }

  Future<void> loadFavorites() async {
    emit(ScanLoading());
    final result = await getFavoriteScansUseCase(FavoriteScansParams());
    result.fold(
      (failure) => emit(ScanError(message: failure.message)),
      (favs) => emit(ScanFavoritesLoaded(favorites: favs)),
    );
  }

  Future<void> loadScanLogById(String id, {ScanLogEntity? initialData}) async {
    emit(ScanDetailLoading());
    print('=== ScanCubit: loadScanLogById called with id: $id ===');
    final cached = CacheHelper.getData(key: 'scanData_$id');
    if (cached != null) {
      try {
        final data = jsonDecode(cached) as Map<String, dynamic>;
        print('=== ScanCubit: loaded from cache: $data ===');
        emit(ScanDetailLoaded(scanLog: ScanLogEntity(
          id: id,
          artifactName: data['artifactName'] ?? initialData?.artifactName,
          description: data['description'],
          era: data['era'] ?? initialData?.era,
          material: data['material'] ?? initialData?.material,
          category: data['category'] ?? initialData?.category,
          type: data['type'] ?? initialData?.type,
          imageUrl: initialData?.imageUrl,
          hieroglyphsTranslation: data['hieroglyphsTranslation'] ?? initialData?.hieroglyphsTranslation,
          isFavorited: initialData?.isFavorited ?? false,
          createdAt: initialData?.createdAt ?? DateTime.now(),
        )));
        return;
      } catch (e) {
        print('=== ScanCubit: cache parse error: $e ===');
      }
    }
    if (initialData != null) {
      print('=== ScanCubit: no cache, using initialData ===');
      emit(ScanDetailLoaded(scanLog: initialData));
    } else {
      emit(ScanError(message: 'No data available'));
    }
  }

  Future<void> toggleFavoriteScan(String scanLogId) async {
    print('=== toggleFavoriteScan: start, current state=${state.runtimeType} isFavorited=${state is ScanDetailLoaded ? (state as ScanDetailLoaded).scanLog.isFavorited : "N/A"} ===');
    // Optimistic local toggle
    if (state is ScanDetailLoaded) {
      final current = state as ScanDetailLoaded;
      final updated = ScanLogEntity(
        id: current.scanLog.id,
        artifactModelId: current.scanLog.artifactModelId,
        artifactName: current.scanLog.artifactName,
        description: current.scanLog.description,
        era: current.scanLog.era,
        material: current.scanLog.material,
        category: current.scanLog.category,
        type: current.scanLog.type,
        imageUrl: current.scanLog.imageUrl,
        hieroglyphsTranslation: current.scanLog.hieroglyphsTranslation,
        isFavorited: !current.scanLog.isFavorited,
        createdAt: current.scanLog.createdAt,
      );
      emit(ScanDetailLoaded(scanLog: updated));
    }
    final result = await toggleFavoriteUseCase(scanLogId);
    result.fold(
      (failure) => emit(ScanError(message: failure.message)),
      (_) {
        if (state is ScanDetailLoaded) {
          // Reload details to sync with backend
          loadScanLogById(scanLogId, initialData: (state as ScanDetailLoaded).scanLog);
        } else if (state is ScanLogsLoaded) {
          loadScanLogs();
        } else {
          loadFavorites();
        }
      },
    );
  }

  /// Just toggles favorite via API without any local state changes or side effects.
  /// Returns true if the API call succeeded.
  Future<bool> silentToggleFavorite(String scanLogId) async {
    final result = await toggleFavoriteUseCase(scanLogId);
    return result.isRight();
  }

  /// Toggles favorite visually in ScanResultLoaded state and calls the API.
  Future<bool> toggleScanResultFavorite(String scanLogId) async {
    if (state is ScanResultLoaded) {
      final current = state as ScanResultLoaded;
      emit(ScanResultLoaded(
        result: current.result,
        imagePath: current.imagePath,
        isFavorited: !current.isFavorited,
      ));
    }
    final ok = await silentToggleFavorite(scanLogId);
    if (!ok && state is ScanResultLoaded) {
      final current = state as ScanResultLoaded;
      emit(ScanResultLoaded(
        result: current.result,
        imagePath: current.imagePath,
        isFavorited: !current.isFavorited,
      ));
    }
    return ok;
  }

  void clearResult() {
    _currentImagePath = null;
    if (!isClosed) emit(ScanInitial());
  }
}
