import 'package:echo_explorer/core/themes/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BaseThemeColors {
  Color get background;
  Color get icons;
  Color get bottomNavBar;
  Color get scanButton;
  Color get discoverAppBar;
  Color get footer;

  Color get textPrimary;
  Color get textSecondary;
  Color get textHint;

  Color get surface;
  Color get divider;

  Color get glassBase;
  Color get glassBorder;
}

class _LightColors implements BaseThemeColors {
  @override
  final background = const Color(0xFFFFFFFF);
  @override
  final icons = const Color(0xFF162410);
  @override
  final bottomNavBar = const Color(0xFFE9E9E9);
  @override
  final scanButton = const Color(0xFF1E2D24);
  @override
  final discoverAppBar = const Color(0xFFE0E4E0);
  @override
  final footer = const Color(0xff162410);
  @override
  final textPrimary = const Color(0xFF162410);
  @override
  final textSecondary = const Color(0xFF5C6B5E);
  @override
  final textHint = const Color(0xFF8E9B90);
  @override
  final surface = const Color(0xFFFFFFFF);
  @override
  final divider = const Color(0xFFD0D6D1);
  @override
  final glassBase = const Color(0xFF162410);
  @override
  final glassBorder = const Color(0xFFC8CEC9);
}

class _DarkColors implements BaseThemeColors {
  @override
  final background = const Color(0xff0d1215);
  @override
  final icons = const Color(0xFFf9f9f9);
  @override
  final bottomNavBar = const Color(0xFF162410);
  @override
  final scanButton = const Color.fromARGB(255, 30, 31, 30);
  @override
  final discoverAppBar = const Color(0xffFFFFFF);
  @override
  final footer = const Color(0xffffffff);
  @override
  final textPrimary = const Color(0xFFF5F5F5);
  @override
  final textSecondary = const Color(0xFFB0B8B2);
  @override
  final textHint = const Color(0xFF6B756D);
  @override
  final surface = const Color(0xFF1A2226);
  @override
  final divider = const Color(0xFF2A3436);
  @override
  final glassBase = const Color(0xFFFFFFFF);
  @override
  final glassBorder = const Color(0xFFFFFFFF);
}

class AppColors {
  static var c151D18 = const Color(0xFF151D18);
  static var c162410 = const Color(0xFF162410);
  static var cf9f9f9 = const Color(0xFFf9f9f9);
  static var cffffff = const Color(0xFFFFFFFF);
  static var c000000 = const Color(0xFF000000);
  static var secondary = const Color(0xFF568D3F);


  static final BaseThemeColors light = _LightColors();
  static final BaseThemeColors dark = _DarkColors();
  static BaseThemeColors of(BuildContext context, {bool listen = true}) {
    final isDark = listen
        ? context.watch<ThemeCubit>().state
        : context.read<ThemeCubit>().state;
    return isDark ? dark : light;
  }
}
