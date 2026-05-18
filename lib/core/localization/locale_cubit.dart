import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/hive/cache_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(_readInitial());

  static const Set<String> _supportedCodes = {'en', 'ar', 'fr', 'de', 'es', 'zh', 'ru', 'it', 'ja', 'ko', 'pt'};

  static LocaleState _readInitial() {
    final raw = CacheHelper.getData(
      key: AppStrings.hiveKeys.cacheHelper.localeLanguageCode,
      defaultValue: 'en',
    );
    final code = raw is String ? raw : 'en';
    final normalized = _supportedCodes.contains(code) ? code : 'en';
    return LocaleState(Locale(normalized));
  }

  Future<void> changeLanguage(String languageCode) async {
    final code = _supportedCodes.contains(languageCode) ? languageCode : 'en';
    final oldLocale = state.locale;
    emit(LocaleState(oldLocale, isLoading: true));
    await CacheHelper.putData(
      key: AppStrings.hiveKeys.cacheHelper.localeLanguageCode,
      value: code,
    );
    await Future.delayed(const Duration(milliseconds: 400));
    emit(LocaleState(Locale(code)));
  }
}
