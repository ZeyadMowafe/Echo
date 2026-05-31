import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/core/hive/cache_helper.dart';
import 'package:echo_explorer/core/usecases/usecase.dart';
import 'package:echo_explorer/features/auth/domain/usecases/google_login_usecase.dart';
import 'package:echo_explorer/features/auth/domain/usecases/login_usecase.dart';
import 'package:echo_explorer/features/auth/domain/usecases/register_usecase.dart';
import 'package:echo_explorer/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:echo_explorer/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GoogleLoginUseCase googleLoginUseCase;
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  bool _initialFetchDone = false;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.googleLoginUseCase,
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(AuthInitial()) {
    _checkSavedLogin();
  }

  Future<void> _checkSavedLogin() async {
    final token = CacheHelper.getData(key: 'jwt_token');

    if (token != null && token.toString().isNotEmpty) {
      final cachedName = CacheHelper.getData(key: 'user_name') ?? 'User';
      final cachedEmail = CacheHelper.getData(key: 'user_email') ?? '';

      emit(Authenticated(userName: cachedName, userEmail: cachedEmail, token: token));

      final result = await getProfileUseCase(NoParams());
      result.fold(
        (failure) {
          debugPrint('Failed to fetch fresh profile data: ${failure.message}');
        },
        (user) {
          if (_initialFetchDone) return;
          _initialFetchDone = true;
          final freshToken = user.token.isNotEmpty ? user.token : token;
          final name = cachedName.isNotEmpty && cachedName != 'User' ? cachedName : user.name;
          final email = cachedEmail.isNotEmpty ? cachedEmail : user.email;
          _saveUserData(freshToken, name, email);
          emit(Authenticated(userName: name, userEmail: email, token: freshToken));
        },
      );
    } else {
      emit(UnAuthenticated());
    }
  }

  Future<void> submitAuth(String email, String password) async {
    emit(AuthLoading());
    final result = await loginUseCase(LoginParams(email: email, password: password));

    result.fold(
      (failure) async {
        final isNotFound = failure is ServerFailure && failure.statusCode == 404;
        if (isNotFound) {
          final lang = CacheHelper.getData(key: 'localeLanguageCode') ?? 'en';
          final registerResult = await registerUseCase(
            RegisterParams(email: email, password: password, name: email.split('@').first, lang: lang),
          );
          registerResult.fold(
            (regFailure) {
              emit(AuthError(message: regFailure.message));
            },
            (user) {
              _saveUserData(user.token, user.name, user.email);
              emit(Authenticated(userName: user.name, userEmail: user.email, token: user.token));
            },
          );
        } else {
          emit(AuthError(message: failure.message));
        }
      },
      (user) {
        _saveUserData(user.token, user.name, user.email);
        emit(Authenticated(userName: user.name, userEmail: user.email, token: user.token));
      },
    );
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
    String lang = 'en',
  }) async {
    emit(AuthLoading());
    final result = await registerUseCase(
      RegisterParams(email: email, password: password, name: name, lang: lang),
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) {
        _saveUserData(user.token, user.name, user.email);
        emit(Authenticated(userName: user.name, userEmail: user.email, token: user.token));
      },
    );
  }

  Future<void> updateProfile({required String newName, required String email, String? lang}) async {
    if (state is! Authenticated) return;
    final token = (state as Authenticated).token;
    final currentLang = lang ?? CacheHelper.getData(key: 'localeLanguageCode') ?? 'en';

    emit(AuthLoading());

    final result = await updateProfileUseCase(UpdateProfileParams(name: newName, email: email, lang: currentLang));

    result.fold(
      (failure) {
        debugPrint('Error updating profile: ${failure.message}');
        emit(AuthError(message: failure.message));
      },
      (_) {
        _initialFetchDone = true;
        _saveUserData(token, newName, email);
        emit(Authenticated(userName: newName, userEmail: email, token: token));
      },
    );
  }

  Future<void> googleSignIn() async {
    emit(AuthLoading());
    try {
      final googleUser = await _signInWithGoogle();
      if (googleUser == null) {
        emit(AuthError(message: 'Google sign-in cancelled'));
        return;
      }
      final idToken = await googleUser.authentication;
      if (idToken.idToken == null) {
        emit(AuthError(message: 'Failed to get Google ID token'));
        return;
      }
      final result = await googleLoginUseCase(GoogleLoginParams(idToken: idToken.idToken!));
      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (user) {
          _saveUserData(user.token, user.name, user.email);
          emit(Authenticated(userName: user.name, userEmail: user.email, token: user.token));
        },
      );
    } catch (e) {
      emit(AuthError(message: 'Google sign-in failed: $e'));
    }
  }

  Future<dynamic> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        // Web Client ID من Google Cloud Console → APIs & Services → Credentials
        // اختار OAuth 2.0 Client ID → Web client → انسخ Client ID
        serverClientId: '441520148279-6d0c4rjrb8gl5i0elsf4mi340u1bnb66.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
      await googleSignIn.signOut(); // ensure fresh login every time
      final account = await googleSignIn.signIn();
      if (account == null) return null;
      return account;
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await CacheHelper.deleteData(key: 'jwt_token');
    await CacheHelper.deleteData(key: 'user_name');
    await CacheHelper.deleteData(key: 'user_email');
    await CacheHelper.deleteData(key: 'profile_image');
    await CacheHelper.deleteData(key: 'cover_image');

    emit(UnAuthenticated());
  }

  Future<void> _saveUserData(String token, String name, String email) async {
    await CacheHelper.putData(key: 'jwt_token', value: token);
    await CacheHelper.putData(key: 'user_name', value: name);
    await CacheHelper.putData(key: 'user_email', value: email);
  }
}
