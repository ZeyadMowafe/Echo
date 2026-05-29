import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/di/injection_container.dart';
import 'package:echo_explorer/core/error/error_handler.dart';
import 'package:echo_explorer/core/localization/locale_cubit.dart';
import 'package:echo_explorer/core/routing/app_router.dart';
import 'package:echo_explorer/core/themes/theme_cubit.dart';
import 'package:echo_explorer/core/widgets/app_loading.dart';
import 'package:echo_explorer/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:echo_explorer/features/home/presentation/cubit/features_cubit.dart';
import 'package:echo_explorer/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    ErrorHandler.logError(
      details.exceptionAsString(),
      details.exception,
      details.stack,
    );
  };

  ui.PlatformDispatcher.instance.onError = (error, stack) {
    ErrorHandler.logError('Platform error', error, stack);
    return true;
  };

  ErrorWidget.builder = (details) => Material(
    color: Colors.transparent,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Something went wrong',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ),
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await init();
  runApp(const EchoExplorer());
}

class EchoExplorer extends StatelessWidget {
  const EchoExplorer({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
        BlocProvider<FeaturesCubit>(create: (_) => FeaturesCubit()),
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<ChatCubit>(create: (_) => sl<ChatCubit>()),
      ],
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, localeState) {
          return ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                key: ValueKey(localeState.locale),
                scaffoldMessengerKey: ErrorHandler.scaffoldMessengerKey,
                title: AppStrings.appName,
                locale: localeState.locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                initialRoute: '/',
                onGenerateRoute: AppRouter().generateRoute,
                debugShowCheckedModeBanner: false,
                // ── أداء عالي: تعطيل الـ debug banner + scroll glow ──
                scrollBehavior: const _SmoothScrollBehavior(),
                // ── تأكيد إلغاء أي انيميشن افتراضي من المنصة ──
                theme: ThemeData(
                  pageTransitionsTheme: const PageTransitionsTheme(
                    builders: {
                      TargetPlatform.android: _NoAnimationPageTransitionsBuilder(),
                      TargetPlatform.iOS: _NoAnimationPageTransitionsBuilder(),
                      TargetPlatform.windows: _NoAnimationPageTransitionsBuilder(),
                      TargetPlatform.macOS: _NoAnimationPageTransitionsBuilder(),
                      TargetPlatform.linux: _NoAnimationPageTransitionsBuilder(),
                    },
                  ),
                ),
                builder: (context, materialChild) {
                  return Stack(
                    children: [
                      materialChild!,
                      if (localeState.isLoading)
                        AppLoading.fullScreen(message: 'Updating language...'),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// ── يزيل تأثير الـ glow عند التمرير للحصول على تجربة سموز احترافية ──
class _SmoothScrollBehavior extends ScrollBehavior {
  const _SmoothScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // لا glow، لا overscroll indicator - تجربة نظيفة تماماً
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // BouncingScrollPhysics لتجربة سموز مثل iOS على كل المنصات
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }
}

/// ── يلغي أي انيميشن افتراضي من المنصة حتى تعمل SmoothRoute فقط ──
class _NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // SmoothRoute يتحكم في الانيميشن بنفسه، هنا نترك الـ child كما هو
    return child;
  }
}
