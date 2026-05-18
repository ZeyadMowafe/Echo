import 'package:dio/dio.dart';
import 'package:echo_explorer/core/error/exceptions.dart';
import 'package:echo_explorer/core/network/api_constants.dart';
import 'package:echo_explorer/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:echo_explorer/features/profile/data/model/profile_model.dart';
import 'package:echo_explorer/features/profile/domain/entities/profile_entity.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<ProfileEntity> getProfile() async {
    try {
      final response = await dio.get(ApiConstants.profile);
      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data);
      } else {
        throw ServerException(message: 'Failed to get profile');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<ProfileEntity> updateProfile({required String name, required String email, required String lang}) async {
    try {
      final response = await dio.put(ApiConstants.profile, data: {
        'name': name,
        'email': email,
        'preferredLanguage': lang,
      });
      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data);
      } else {
        throw ServerException(message: 'Failed to update profile');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message);
    }
  }
}
