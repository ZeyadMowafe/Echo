import 'package:dio/dio.dart';
import 'package:echo_explorer/core/error/exceptions.dart';
import 'package:echo_explorer/core/network/api_constants.dart';
import 'package:echo_explorer/features/chat/data/models/chat_reply_model.dart';
import 'package:echo_explorer/features/chat/data/models/session_model.dart';

abstract class ChatRemoteDataSource {
  Future<ChatReplyModel> sendMessage({
    required String message,
    required String language,
    String? artifactId,
    String? sessionId,
  });
  Future<List<SessionModel>> getSessions({int limit = 20});
  Future<SessionModel> getSessionById(String id);
  Future<void> renameSession(String id, String title);
  Future<void> deleteSession(String id);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio dio;

  ChatRemoteDataSourceImpl({required this.dio});

  @override
  Future<ChatReplyModel> sendMessage({
    required String message,
    required String language,
    String? artifactId,
    String? sessionId,
  }) async {
    try {
      final body = <String, dynamic>{'message': message, 'language': language};
      if (artifactId != null) body['artifactId'] = artifactId;
      if (sessionId != null) body['sessionId'] = sessionId;

      final response = await dio.post(
        ApiConstants.chat,
        data: body,
        options: Options(
          connectTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 120),
        ),
      );
      if (response.statusCode == 200) {
        return ChatReplyModel.fromJson(response.data);
      } else {
        throw ServerException(message: 'Failed to send message');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<SessionModel>> getSessions({int limit = 20}) async {
    try {
      final response = await dio.get(
        ApiConstants.sessions,
        queryParameters: {'limit': limit},
      );
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((s) => SessionModel.fromJson(s))
            .toList();
      } else {
        throw ServerException(message: 'Failed to get sessions');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<SessionModel> getSessionById(String id) async {
    try {
      final response = await dio.get('${ApiConstants.sessions}/$id');
      if (response.statusCode == 200) {
        return SessionModel.fromJson(response.data);
      } else {
        throw ServerException(message: 'Failed to get session');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> renameSession(String id, String title) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.sessions}/$id',
        data: {'title': title},
      );
      if (response.statusCode != 204) {
        throw ServerException(message: 'Failed to rename session');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteSession(String id) async {
    try {
      final response = await dio.delete('${ApiConstants.sessions}/$id');
      if (response.statusCode != 204) {
        throw ServerException(message: 'Failed to delete session');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }
}
