import 'dart:convert';
import 'dart:io';
import 'package:echo_explorer/core/hive/cache_helper.dart';
import 'package:echo_explorer/features/scanner/data/services/image_filter_pipeline/duplicate_gate.dart';
import 'package:echo_explorer/features/scanner/data/services/image_filter_pipeline/photo_pipeline.dart';
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

  final PhotoPipeline photoPipeline;

  List<ScanLogEntity>? _cachedScanLogs;
  List<ScanLogEntity>? _cachedFavorites;

  bool get hasCachedScanLogs => _cachedScanLogs != null;
  bool get hasCachedFavorites => _cachedFavorites != null;

  String? _currentImagePath;
  String? get currentImagePath => _currentImagePath;

  ScanCubit({
    required this.analyzeImageUseCase,
    required this.getScanLogsUseCase,
    required this.getFavoriteScansUseCase,
    required this.toggleFavoriteUseCase,
    PhotoPipeline? photoPipeline,
  }) : photoPipeline = photoPipeline ?? PhotoPipeline(),
       super(ScanInitial());

  void setImagePath(String path) {
    _currentImagePath = path;
    emit(ScanImagePicked(imagePath: path));
  }

  void clearSession() {
    photoPipeline.reset();
  }

  Future<void> analyzeImage({String? language}) async {
    if (_currentImagePath == null) return;
    if (!isClosed) emit(ScanLoading());

    final file = File(_currentImagePath!);
    final result = await photoPipeline.processPhoto(file);

    if (result.rejection != null) {
      if (!isClosed) {
        emit(
          ScanFilterRejected(
            reason: result.message ?? 'Image rejected',
            sharpness: result.sharpness,
          ),
        );
      }
      return;
    }

    // ── Duplicate Detection ──
    final imageHash = await DuplicateGate.computeHash(result.file!);
    final cachedResponse = DuplicateGate.getCachedResult(imageHash);
    if (cachedResponse != null) {
      if (!isClosed) {
        if (cachedResponse.artifact.name == null &&
            cachedResponse.artifact.description == null &&
            cachedResponse.artifact.era == null &&
            cachedResponse.artifact.imageUrl == null) {
          emit(ScanNoArtifactDetected(imagePath: _currentImagePath));
        } else {
          emit(
            ScanAnchored(result: cachedResponse, imagePath: _currentImagePath),
          );
        }
      }
      return;
    }

    final lang =
        language ?? CacheHelper.getData(key: 'localeLanguageCode') ?? 'en';
    final apiResult = await analyzeImageUseCase(
      AnalyzeImageParams(imagePath: result.file!.path, language: lang),
    );
    if (isClosed) return;
    apiResult.fold(
      (failure) {
        if (!isClosed) emit(ScanError(message: failure.message));
      },
      (response) {
        final scanLogId = response.scanLogId;
        if (scanLogId != null) {
          // Cache full response for duplicate detection
          DuplicateGate.cacheResult(imageHash, scanLogId, response);
          // Cache minimal data for offline log detail view
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
              'isFavorited': false,
            }),
          );
        }
        if (!isClosed) {
          if (response.artifact.name == null &&
              response.artifact.description == null &&
              response.artifact.era == null &&
              response.artifact.imageUrl == null) {
            emit(ScanNoArtifactDetected(imagePath: _currentImagePath));
          } else {
            emit(ScanAnchored(result: response, imagePath: _currentImagePath));
          }
        }
      },
    );
  }

  /// Removes duplicate artifacts from scan logs/favorites by [artifactModelId] or [artifactName].
  /// Favorited entries take priority; among equal favorites, keeps the most recent.
  List<ScanLogEntity> _deduplicate(List<ScanLogEntity> logs) {
    final seen = <String>{};
    final result = <ScanLogEntity>[];

    final sorted = List<ScanLogEntity>.from(logs)
      ..sort((a, b) {
        if (a.isFavorited != b.isFavorited) {
          return a.isFavorited ? -1 : 1;
        }
        return b.createdAt.compareTo(a.createdAt);
      });

    for (final log in sorted) {
      final key = log.artifactModelId ?? log.artifactName ?? log.id;
      if (seen.add(key)) {
        result.add(log);
      }
    }

    return result;
  }

  Future<void> loadScanLogs() async {
    emit(ScanLoading());
    final result = await getScanLogsUseCase(ScanLogsParams());
    result.fold((failure) => emit(ScanError(message: failure.message)), (logs) {
      _cachedScanLogs = _deduplicate(logs);
      emit(ScanLogsLoaded(scanLogs: _cachedScanLogs!));
    });
  }

  Future<void> loadFavorites() async {
    emit(ScanLoading());
    final result = await getFavoriteScansUseCase(FavoriteScansParams());
    result.fold((failure) => emit(ScanError(message: failure.message)), (favs) {
      _cachedFavorites = _deduplicate(favs);
      emit(ScanFavoritesLoaded(favorites: _cachedFavorites!));
    });
  }

  void silentReloadFavorites() {
    if (_cachedFavorites != null && !isClosed) {
      emit(ScanFavoritesLoaded(favorites: _cachedFavorites!));
    }
  }

  void silentReloadScanLogs() {
    if (_cachedScanLogs != null && !isClosed) {
      emit(ScanLogsLoaded(scanLogs: _cachedScanLogs!));
    }
  }

  void _applyFavoriteToggle(String scanLogId, bool isFavorited) {
    if (_cachedScanLogs != null) {
      _cachedScanLogs = _cachedScanLogs!.map((log) {
        if (log.id == scanLogId) {
          return ScanLogEntity(
            id: log.id,
            artifactModelId: log.artifactModelId,
            artifactName: log.artifactName,
            description: log.description,
            era: log.era,
            material: log.material,
            category: log.category,
            type: log.type,
            imageUrl: log.imageUrl,
            hieroglyphsTranslation: log.hieroglyphsTranslation,
            isFavorited: isFavorited,
            isPrimaryModel: log.isPrimaryModel,
            createdAt: log.createdAt,
          );
        }
        return log;
      }).toList();
      if (state is ScanLogsLoaded) {
        emit(ScanLogsLoaded(scanLogs: _cachedScanLogs!));
      }
    }
    if (_cachedFavorites != null) {
      if (!isFavorited) {
        _cachedFavorites = _cachedFavorites!
            .where((l) => l.id != scanLogId)
            .toList();
      } else {
        final alreadyExists = _cachedFavorites!.any((l) => l.id == scanLogId);
        if (alreadyExists) {
          // Update existing entry
          _cachedFavorites = _cachedFavorites!.map((log) {
            if (log.id == scanLogId) {
              return ScanLogEntity(
                id: log.id,
                artifactModelId: log.artifactModelId,
                artifactName: log.artifactName,
                description: log.description,
                era: log.era,
                material: log.material,
                category: log.category,
                type: log.type,
                imageUrl: log.imageUrl,
                hieroglyphsTranslation: log.hieroglyphsTranslation,
                isFavorited: true,
                isPrimaryModel: log.isPrimaryModel,
                createdAt: log.createdAt,
              );
            }
            return log;
          }).toList();
        } else {
          // Item is new to favorites — find it in scan logs cache and prepend it
          final source = _cachedScanLogs?.firstWhere(
            (l) => l.id == scanLogId,
            orElse: () => ScanLogEntity(
              id: scanLogId,
              isFavorited: true,
              createdAt: DateTime.now(),
            ),
          );
          if (source != null) {
            final newEntry = ScanLogEntity(
              id: source.id,
              artifactModelId: source.artifactModelId,
              artifactName: source.artifactName,
              description: source.description,
              era: source.era,
              material: source.material,
              category: source.category,
              type: source.type,
              imageUrl: source.imageUrl,
              hieroglyphsTranslation: source.hieroglyphsTranslation,
              isFavorited: true,
              isPrimaryModel: source.isPrimaryModel,
              createdAt: source.createdAt,
            );
            _cachedFavorites = [newEntry, ..._cachedFavorites!];
          }
        }
      }
      emit(ScanFavoritesLoaded(favorites: _cachedFavorites!));
    } else if (isFavorited) {
      // _cachedFavorites not yet loaded — seed it with this item from scan logs
      final source = _cachedScanLogs?.firstWhere(
        (l) => l.id == scanLogId,
        orElse: () => ScanLogEntity(
          id: scanLogId,
          isFavorited: true,
          createdAt: DateTime.now(),
        ),
      );
      if (source != null) {
        _cachedFavorites = [
          ScanLogEntity(
            id: source.id,
            artifactModelId: source.artifactModelId,
            artifactName: source.artifactName,
            description: source.description,
            era: source.era,
            material: source.material,
            category: source.category,
            type: source.type,
            imageUrl: source.imageUrl,
            hieroglyphsTranslation: source.hieroglyphsTranslation,
            isFavorited: true,
            isPrimaryModel: source.isPrimaryModel,
            createdAt: source.createdAt,
          ),
        ];
        emit(ScanFavoritesLoaded(favorites: _cachedFavorites!));
      }
    }
  }

  Future<void> loadScanLogById(String id, {ScanLogEntity? initialData}) async {
    emit(ScanDetailLoading());
    final cached = CacheHelper.getData(key: 'scanData_$id');
    if (cached != null) {
      try {
        final data = jsonDecode(cached) as Map<String, dynamic>;
        emit(
          ScanDetailLoaded(
            scanLog: ScanLogEntity(
              id: id,
              artifactName: data['artifactName'] ?? initialData?.artifactName,
              description: data['description'],
              era: data['era'] ?? initialData?.era,
              material: data['material'] ?? initialData?.material,
              category: data['category'] ?? initialData?.category,
              type: data['type'] ?? initialData?.type,
              imageUrl: initialData?.imageUrl,
              hieroglyphsTranslation:
                  data['hieroglyphsTranslation'] ??
                  initialData?.hieroglyphsTranslation,
              isFavorited:
                  data['isFavorited'] as bool? ??
                  initialData?.isFavorited ??
                  false,
              isPrimaryModel: initialData?.isPrimaryModel ?? false,
              createdAt: initialData?.createdAt ?? DateTime.now(),
            ),
          ),
        );
        return;
      } catch (_) {}
    }
    if (initialData != null) {
      emit(ScanDetailLoaded(scanLog: initialData));
    } else {
      emit(ScanError(message: 'No data available'));
    }
  }

  Future<void> toggleFavoriteScan(String scanLogId) async {
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
        isPrimaryModel: current.scanLog.isPrimaryModel,
        createdAt: current.scanLog.createdAt,
      );
      emit(ScanDetailLoaded(scanLog: updated));
    }
    final newIsFavorited = state is ScanDetailLoaded
        ? (state as ScanDetailLoaded).scanLog.isFavorited
        : false;
    final result = await toggleFavoriteUseCase(scanLogId);
    result.fold((failure) => emit(ScanError(message: failure.message)), (_) {
      _updateCachedFavoriteStatus(scanLogId, newIsFavorited);
      _applyFavoriteToggle(scanLogId, newIsFavorited);
      if (state is ScanDetailLoaded) {
        loadScanLogById(
          scanLogId,
          initialData: (state as ScanDetailLoaded).scanLog,
        );
      } else if (state is ScanLogsLoaded) {
        loadScanLogs();
      } else {
        loadFavorites();
      }
    });
  }

  Future<bool> silentToggleFavorite(String scanLogId) async {
    final result = await toggleFavoriteUseCase(scanLogId);
    return result.isRight();
  }

  Future<bool> toggleScanResultFavorite(String scanLogId) async {
    if (state is ScanResultLoaded) {
      final current = state as ScanResultLoaded;
      emit(
        ScanResultLoaded(
          result: current.result,
          imagePath: current.imagePath,
          isFavorited: !current.isFavorited,
        ),
      );
    } else if (state is ScanAnchored) {
      final current = state as ScanAnchored;
      emit(
        ScanAnchored(
          result: current.result,
          imagePath: current.imagePath,
          isFavorited: !current.isFavorited,
        ),
      );
    }
    final newIsFavorited = state is ScanResultLoaded
        ? (state as ScanResultLoaded).isFavorited
        : state is ScanAnchored
        ? (state as ScanAnchored).isFavorited
        : false;
    final ok = await silentToggleFavorite(scanLogId);
    if (!ok) {
      if (state is ScanResultLoaded) {
        final current = state as ScanResultLoaded;
        emit(
          ScanResultLoaded(
            result: current.result,
            imagePath: current.imagePath,
            isFavorited: !current.isFavorited,
          ),
        );
      } else if (state is ScanAnchored) {
        final current = state as ScanAnchored;
        emit(
          ScanAnchored(
            result: current.result,
            imagePath: current.imagePath,
            isFavorited: !current.isFavorited,
          ),
        );
      }
    } else {
      _updateCachedFavoriteStatus(scanLogId, newIsFavorited);
      _applyFavoriteToggle(scanLogId, newIsFavorited);
    }
    return ok;
  }

  Future<void> _updateCachedFavoriteStatus(
    String scanLogId,
    bool isFavorited,
  ) async {
    final cached = CacheHelper.getData(key: 'scanData_$scanLogId');
    if (cached != null) {
      try {
        final data = jsonDecode(cached) as Map<String, dynamic>;
        data['isFavorited'] = isFavorited;
        await CacheHelper.putData(
          key: 'scanData_$scanLogId',
          value: jsonEncode(data),
        );
      } catch (_) {}
    }
  }

  void clearResult() {
    _currentImagePath = null;
    photoPipeline.reset();
    if (!isClosed) emit(ScanInitial());
  }
}
