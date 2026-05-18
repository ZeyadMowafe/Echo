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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  late final Map<String, Widget> _features = {
    AppStrings.homeFeature.key: HomeContent(
    ),
    AppStrings.discoverFeature.key: DiscoverBody(
    ),
    AppStrings.profileFeature.key: ProfileView(key: ValueKey(_profileTabIndex)),
  };

  @override
  Widget build(BuildContext context) {
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
                _features[AppStrings.profileFeature.key] = ProfileView(key: ValueKey(_profileTabIndex));
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
        endDrawer: CustomGlassDrawer(
          currentFeature: state.featureName,
          onTap: (featureName) {
            context.read<FeaturesCubit>().changeFeature(
              featureName: featureName,
            );
            Navigator.pop(context);
          },
        ),
        endDrawerEnableOpenDragGesture: false,
        drawerBarrierDismissible: false,
        body: _features[state.featureName] ?? _features[AppStrings.homeFeature.key]!,

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
