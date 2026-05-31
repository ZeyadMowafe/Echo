import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:echo_explorer/core/config/app_config.dart';
import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/error/error_handler.dart';
import 'package:echo_explorer/core/hive/cache_helper.dart';
import 'package:echo_explorer/core/network/api_constants.dart';
import 'package:echo_explorer/core/network/network_info.dart';
import 'package:echo_explorer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:echo_explorer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:echo_explorer/features/auth/domain/repositories/auth_repository.dart';
import 'package:echo_explorer/features/auth/domain/usecases/get_profile_usecase.dart' as auth;
import 'package:echo_explorer/features/auth/domain/usecases/google_login_usecase.dart';
import 'package:echo_explorer/features/auth/domain/usecases/login_usecase.dart';
import 'package:echo_explorer/features/auth/domain/usecases/register_usecase.dart';
import 'package:echo_explorer/features/auth/domain/usecases/update_profile_usecase.dart' as auth_up;
import 'package:echo_explorer/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:echo_explorer/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:echo_explorer/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:echo_explorer/features/chat/domain/repositories/chat_repository.dart';
import 'package:echo_explorer/features/scanner/data/datasources/scan_remote_data_source.dart';
import 'package:echo_explorer/features/scanner/data/repositories/scan_repository_impl.dart';
import 'package:echo_explorer/features/scanner/domain/repositories/scan_repository.dart';
import 'package:echo_explorer/features/scanner/domain/usecases/analyze_image_usecase.dart';
import 'package:echo_explorer/features/scanner/domain/usecases/get_favorite_scans_usecase.dart';
import 'package:echo_explorer/features/scanner/domain/usecases/get_scan_logs_usecase.dart';
import 'package:echo_explorer/features/scanner/domain/usecases/toggle_favorite_usecase.dart';
import 'package:echo_explorer/features/scanner/presentation/cubit/scan_cubit.dart';
import 'package:echo_explorer/features/chat/domain/usecases/delete_session_usecase.dart';
import 'package:echo_explorer/features/chat/domain/usecases/get_session_by_id_usecase.dart';
import 'package:echo_explorer/features/chat/domain/usecases/get_sessions_usecase.dart';
import 'package:echo_explorer/features/chat/domain/usecases/rename_session_usecase.dart';
import 'package:echo_explorer/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:echo_explorer/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:echo_explorer/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:echo_explorer/features/profile/data/datasources/profile_remote_data_source_impl.dart';
import 'package:echo_explorer/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:echo_explorer/features/profile/domain/repositories/profile_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await _initHive();

  //! Features - Auth
  // Cubits
  sl.registerFactory(() => AuthCubit(
        loginUseCase: sl(),
        registerUseCase: sl(),
        googleLoginUseCase: sl(),
        getProfileUseCase: sl(),
        updateProfileUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GoogleLoginUseCase(sl()));
  sl.registerLazySingleton<auth.GetProfileUseCase>(() => auth.GetProfileUseCase(sl()));
  sl.registerLazySingleton<auth_up.UpdateProfileUseCase>(() => auth_up.UpdateProfileUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  //! Features - Profile
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(dio: sl()),
  );

  //! Features - Chat
  sl.registerFactory(() => ChatCubit(
        sendMessageUseCase: sl(),
        getSessionsUseCase: sl(),
        getSessionByIdUseCase: sl(),
        renameSessionUseCase: sl(),
        deleteSessionUseCase: sl(),
      ));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => GetSessionsUseCase(sl()));
  sl.registerLazySingleton(() => GetSessionByIdUseCase(sl()));
  sl.registerLazySingleton(() => RenameSessionUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSessionUseCase(sl()));
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(dio: sl()),
  );

  //! Features - Scanner
  sl.registerFactory(() => ScanCubit(
        analyzeImageUseCase: sl(),
        getScanLogsUseCase: sl(),
        getFavoriteScansUseCase: sl(),
        toggleFavoriteUseCase: sl(),
      ));
  sl.registerLazySingleton(() => AnalyzeImageUseCase(sl()));
  sl.registerLazySingleton(() => GetScanLogsUseCase(sl()));
  sl.registerLazySingleton(() => GetFavoriteScansUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFavoriteUseCase(sl()));
  sl.registerLazySingleton<ScanRepository>(
    () => ScanRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<ScanRemoteDataSource>(
    () => ScanRemoteDataSourceImpl(dio: sl()),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(connectivity: sl()));

  //! External
  sl.registerLazySingleton<Dio>(() => _createDio());
  sl.registerLazySingleton(() => Connectivity());
}

Dio _createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      receiveDataWhenStatusError: true,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = CacheHelper.getData(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        ErrorHandler.logError(
          'Dio error: ${error.requestOptions.uri}',
          error,
          error.stackTrace,
        );
        if (error.response?.statusCode == 401) {
          CacheHelper.deleteData(key: 'jwt_token');
          CacheHelper.deleteData(key: 'user_name');
          CacheHelper.deleteData(key: 'user_email');
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  await Hive.openBox(AppStrings.hiveKeys.cacheHelper.boxName);
  CacheHelper.isOnboardingCompleted = CacheHelper.getData(
    key: AppStrings.hiveKeys.cacheHelper.isOnboardingCompleted,
    defaultValue: false,
  );
}
