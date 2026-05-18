part of 'scan_cubit.dart';

abstract class ScanState {}

class ScanInitial extends ScanState {}

class ScanImagePicked extends ScanState {
  final String imagePath;
  ScanImagePicked({required this.imagePath});
}

class ScanLoading extends ScanState {}

class ScanResultLoaded extends ScanState {
  final ScanResponseEntity result;
  final String? imagePath;
  final bool isFavorited;
  ScanResultLoaded({required this.result, this.imagePath, this.isFavorited = false});
}

class ScanLogsLoaded extends ScanState {
  final List<ScanLogEntity> scanLogs;
  ScanLogsLoaded({required this.scanLogs});
}

class ScanFavoritesLoaded extends ScanState {
  final List<ScanLogEntity> favorites;
  ScanFavoritesLoaded({required this.favorites});
}

class ScanFavoriteToggled extends ScanState {
  final String scanLogId;
  final bool isFavorited;
  ScanFavoriteToggled({required this.scanLogId, required this.isFavorited});
}

class ScanDetailLoading extends ScanState {}

class ScanDetailLoaded extends ScanState {
  final ScanLogEntity scanLog;
  ScanDetailLoaded({required this.scanLog});
}

class ScanError extends ScanState {
  final String message;
  ScanError({required this.message});
}
