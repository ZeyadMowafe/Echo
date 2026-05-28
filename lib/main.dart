import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/di/injection_container.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/core/localization/locale_cubit.dart';
import 'package:echo_explorer/core/routing/app_router.dart';
import 'package:echo_explorer/core/themes/theme_cubit.dart';
import 'package:echo_explorer/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:echo_explorer/features/home/presentation/cubit/features_cubit.dart';
import 'package:echo_explorer/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
                title: AppStrings.appName,
                locale: localeState.locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                initialRoute: '/',
                onGenerateRoute: AppRouter().generateRoute,
                debugShowCheckedModeBanner: false,
                builder: (context, materialChild) {
                  return Stack(
                    children: [
                      materialChild!,
                      if (localeState.isLoading)
                        Container(
                          color: const Color(0xFF0F1914),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(color: Colors.white),
                                Gap(ScreenUtils.md),
                                Text(
                                  'Updating language...',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
