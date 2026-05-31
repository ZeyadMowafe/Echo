import 'package:dio/dio.dart';
import 'package:echo_explorer/core/error/exceptions.dart';
import 'package:echo_explorer/core/network/api_constants.dart';
import 'package:echo_explorer/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({required String email, required String password, required String name, String lang = 'en'});
  Future<UserModel> googleLogin({required String idToken});
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({required String name, required String email, required String lang});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  String _parseErrorMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map) {
        return data['message'] ?? data['error'] ?? e.message ?? 'Unknown error';
      }
    } catch (_) {}
    return e.message ?? 'Unknown error';
  }

  String _parseErrorFromResponse(dynamic data, String fallback) {
    try {
      if (data is Map) {
        return data['message'] ?? data['error'] ?? fallback;
      }
    } catch (_) {}
    return fallback;
  }

  @override
  Future<UserModel> login({required String email, required String password}) async {
    try {
      final response = await dio.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data, fallbackName: email.split('@').first);
      } else {
        throw ServerException(
          message: _parseErrorFromResponse(response.data, 'Login failed'),
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(message: _parseErrorMessage(e), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<UserModel> register({required String email, required String password, required String name, String lang = 'en'}) async {
    try {
      final response = await dio.post(ApiConstants.register, data: {
        'email': email,
        'password': password,
        'name': name,
        'preferredLanguage': lang,
      });
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data, fallbackName: name);
      } else {
        throw ServerException(
          message: _parseErrorFromResponse(response.data, 'Registration failed'),
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(message: _parseErrorMessage(e), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<UserModel> googleLogin({required String idToken}) async {
    try {
      final response = await dio.post(ApiConstants.googleLogin, data: {
        'idToken': idToken,
      });
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }
      throw ServerException(
        message: _parseErrorFromResponse(response.data, 'Google login failed'),
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException(message: _parseErrorMessage(e), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await dio.get(ApiConstants.profile);
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: _parseErrorFromResponse(response.data, 'Failed to get profile'),
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(message: _parseErrorMessage(e), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<UserModel> updateProfile({required String name, required String email, required String lang}) async {
    try {
      final response = await dio.put(ApiConstants.profile, data: {
        'name': name,
        'email': email,
        'preferredLanguage': lang,
      });
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: _parseErrorFromResponse(response.data, 'Failed to update profile'),
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(message: _parseErrorMessage(e), statusCode: e.response?.statusCode);
    }
  }
}
