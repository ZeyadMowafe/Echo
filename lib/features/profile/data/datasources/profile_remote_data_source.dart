import 'package:echo_explorer/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileEntity> getProfile();
  Future<ProfileEntity> updateProfile({required String name, required String email, required String lang});
}
