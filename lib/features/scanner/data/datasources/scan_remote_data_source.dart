import 'package:dio/dio.dart';
import 'package:echo_explorer/core/error/exceptions.dart';
import 'package:echo_explorer/core/network/api_constants.dart';
import 'package:echo_explorer/features/scanner/data/models/scan_log_model.dart';
import 'package:echo_explorer/features/scanner/data/models/scan_response_model.dart';

abstract class ScanRemoteDataSource {
  Future<ScanResponseModel> analyzeImage({required String imagePath, required String language});
  Future<List<ScanLogModel>> getScanLogs({int page = 1, int pageSize = 20});
  Future<List<ScanLogModel>> getFavoriteScans({int page = 1, int pageSize = 20});
  Future<void> toggleFavorite(String scanLogId);
}

class ScanRemoteDataSourceImpl implements ScanRemoteDataSource {
  final Dio dio;

  ScanRemoteDataSourceImpl({required this.dio});

  @override
  Future<ScanResponseModel> analyzeImage({required String imagePath, required String language}) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath, filename: 'scan.jpg'),
      });
      final response = await dio.post(
        '${ApiConstants.analyze}?lang=$language',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          receiveTimeout: const Duration(seconds: 60),
          connectTimeout: const Duration(seconds: 60),
        ),
      );
      if (response.statusCode == 200) {
        print('=== AnalyzeImage full response: ${response.data} ===');
        return ScanResponseModel.fromJson(response.data);
      }
      throw ServerException(message: 'Failed to analyze image');
    } on DioException catch (e) {
      throw ServerException(message: e.message, statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<List<ScanLogModel>> getScanLogs({int page = 1, int pageSize = 20}) async {
    try {
      final response = await dio.get(
        ApiConstants.scanLogs,
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as List? ?? [];
        return data.map((s) => ScanLogModel.fromJson(s)).toList();
      }
      throw ServerException(message: 'Failed to get scan logs');
    } on DioException catch (e) {
      throw ServerException(message: e.message, statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<List<ScanLogModel>> getFavoriteScans({int page = 1, int pageSize = 20}) async {
    try {
      final response = await dio.get(
        ApiConstants.scanLogsFavorites,
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as List? ?? [];
        return data.map((s) => ScanLogModel.fromJson(s)).toList();
      }
      throw ServerException(message: 'Failed to get favorite scans');
    } on DioException catch (e) {
      throw ServerException(message: e.message, statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> toggleFavorite(String scanLogId) async {
    try {
      print('=== ToggleFavorite: Calling PATCH /api/scanlogs/$scanLogId/favorite ===');
      final response = await dio.patch(
        '${ApiConstants.scanLogs}/$scanLogId/favorite',
        data: {'isFavorited': true},
      );
      print('=== ToggleFavorite: Response status: ${response.statusCode} ===');
      print('=== ToggleFavorite: Response body: ${response.data} ===');
      if (response.statusCode == 200 || response.statusCode == 204) return;
      throw ServerException(message: 'Failed to toggle favorite (status ${response.statusCode})');
    } on DioException catch (e) {
      print('=== ToggleFavorite: DioException ${e.response?.statusCode} - ${e.message} ===');
      print('=== ToggleFavorite: Response data: ${e.response?.data} ===');
      throw ServerException(message: e.message, statusCode: e.response?.statusCode);
    }
  }
}
