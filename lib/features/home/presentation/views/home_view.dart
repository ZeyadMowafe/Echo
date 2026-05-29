import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/routing/routes.dart';
import 'package:echo_explorer/core/widgets/custom_bottom_nav_bar.dart';
import 'package:echo_explorer/core/widgets/custom_floating_action_button.dart';
import 'package:echo_explorer/core/widgets/custom_glass_drawer.dart';
import 'package:echo_explorer/features/discover/presentation/widgets/discover_body.dart';
import 'package:echo_explorer/features/home/presentation/cubit/features_cubit.dart';
import 'package:echo_explorer/features/home/presentation/cubit/features_states.dart';
import 'package:echo_explorer/features/home/presentation/views/widgets/home_content.dart';
import 'package:echo_explorer/features/profile/presentation/views/profile_view.dart';
import 'package:echo_explorer/core/themes/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _profileTabIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _applySystemUiOverlay(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildBody(String featureName) {
    if (featureName == AppStrings.discoverFeature.key) {
      return const DiscoverBody(key: ValueKey('discover_body'));
    } else if (featureName == AppStrings.profileFeature.key) {
      return ProfileView(key: ValueKey('profile_view'));
    } else {
      return const HomeContent(key: ValueKey('home_content'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    _applySystemUiOverlay(isDark);
    return BlocConsumer<FeaturesCubit, FeaturesStates>(
      listenWhen: (previous, current) {
        return current.featureName == AppStrings.chatFeature.key ||
            current.featureName == AppStrings.scanFeature.key ||
            current.featureName == AppStrings.settingsFeature.key;
      },
      buildWhen: (previous, current) {
        return current.featureName != AppStrings.chatFeature.key &&
            current.featureName != AppStrings.scanFeature.key &&
            current.featureName != AppStrings.settingsFeature.key;
      },
      listener: (context, state) {
        if (state is FeatureChangedState) {
          if (state.featureName == AppStrings.chatFeature.key) {
            Navigator.pushNamed(context, AppRoutes.chatView).then((_) {
              if (context.mounted) {
                context.read<FeaturesCubit>().changeFeature(featureName: AppStrings.homeFeature.key);
              }
            });
          } else if (state.featureName == AppStrings.scanFeature.key) {
            Navigator.pushNamed(context, AppRoutes.scanView).then((result) {
              if (result == 'navigate_to_favorites' && context.mounted) {
                setState(() => _profileTabIndex++);
                context.read<FeaturesCubit>().changeFeature(featureName: AppStrings.profileFeature.key);
              } else if (context.mounted) {
                context.read<FeaturesCubit>().changeFeature(featureName: AppStrings.homeFeature.key);
              }
            });
          } else if (state.featureName == AppStrings.settingsFeature.key) {
            Navigator.pushNamed(context, AppRoutes.settingsView).then((_) {
              if (context.mounted) {
                context.read<FeaturesCubit>().changeFeature(featureName: AppStrings.homeFeature.key);
              }
            });
          }
        }
      },
      builder: (context, state) => Scaffold(
        backgroundColor: AppColors.of(context).background,
        drawer: CustomGlassDrawer(
          currentFeature: state.featureName,
          onTap: (featureName) {
            context.read<FeaturesCubit>().changeFeature(
              featureName: featureName,
            );
            Navigator.pop(context);
          },
        ),
        drawerBarrierDismissible: true,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: _buildBody(state.featureName),
        ),

        floatingActionButton: CustomFloatingActionButton(
          onPressed: () {
            context.read<FeaturesCubit>().changeFeature(
              featureName: AppStrings.scanFeature.key,
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: CustomBottomNavBar(
          currentFeature: state.featureName,
          onTap: (featureName) {
            context.read<FeaturesCubit>().changeFeature(
              featureName: featureName,
            );
          },
        ),
      ),
    );
  }
}
