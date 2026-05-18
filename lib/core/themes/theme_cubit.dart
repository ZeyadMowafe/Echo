import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:echo_explorer/core/hive/cache_helper.dart'; // مسار الكاش بتاعك

class ThemeCubit extends Cubit<bool> {
  // الحالة هنا عبارة عن bool (true = Dark, false = Light)
  // هنخلي الدارك هو الافتراضي
  ThemeCubit() : super(true) {
    _loadTheme();
  }

  void _loadTheme() {
    // بنقرأ الثيم من الكاش، لو مفيش بنخليه true (Dark)
    final isDark = CacheHelper.getData(key: 'is_dark_mode') ?? true;
    emit(isDark);
  }

  Future<void> toggleTheme(bool isLight) async {
    final isDark = !isLight;
    await CacheHelper.putData(key: 'is_dark_mode', value: isDark);
    emit(isDark);
  }
}