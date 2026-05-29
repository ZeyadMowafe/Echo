import 'package:echo_explorer/core/routing/app_transitions.dart';
import 'package:echo_explorer/core/routing/routes.dart';
import 'package:echo_explorer/features/auth/presentation/views/auth_view.dart';
import 'package:echo_explorer/features/chat/presentation/views/chat_view.dart';
import 'package:echo_explorer/features/discover/presentation/views/egyptian_history_view.dart';
import 'package:echo_explorer/features/discover/presentation/views/god_details_view.dart';
import 'package:echo_explorer/features/discover/presentation/views/mythology_view.dart';
import 'package:echo_explorer/features/home/presentation/views/home_view.dart';
import 'package:echo_explorer/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:echo_explorer/features/profile/presentation/views/edit_profile_view.dart';
import 'package:echo_explorer/features/profile/presentation/views/settings_view.dart';
import 'package:echo_explorer/features/scanner/presentation/views/scanner_view.dart';
import 'package:echo_explorer/features/splash/presentation/views/splash_view.dart';
import 'package:flutter/material.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return SmoothRoute(
          settings: settings,
          type: TransitionType.fade,
          page: const SplashView(),
        );

      case AppRoutes.homeView:
        return SmoothRoute(
          settings: settings,
          type: TransitionType.fade,
          page: const HomeView(),
        );

      case AppRoutes.onboardingView:
        return SmoothRoute(
          settings: settings,
          type: TransitionType.fade,
          page: const OnboardingView(),
        );

      case AppRoutes.authView:
        return SmoothRoute(
          settings: settings,
          type: TransitionType.fadeSlideUp,
          page: const AuthView(),
        );

      case AppRoutes.chatView:
        final chatArgs = settings.arguments;
        if (chatArgs is Map<String, dynamic>) {
          return SmoothRoute(
            settings: settings,
            type: TransitionType.fadeSlideUp,
            page: ChatView(
              artifactId: chatArgs['artifactId'] as String?,
              artifactName: chatArgs['artifactName'] as String?,
            ),
          );
        }
        return SmoothRoute(
          settings: settings,
          type: TransitionType.fadeSlideUp,
          page: const ChatView(),
        );

      case AppRoutes.scanView:
        return SmoothRoute(
          settings: settings,
          type: TransitionType.fadeSlideUp,
          page: const ScannerView(),
        );

      case AppRoutes.settingsView:
        return SmoothRoute(
          settings: settings,
          type: TransitionType.fadeSlideRight,
          page: const SettingsView(),
        );

      case AppRoutes.godDetailsView:
        final godIndex = settings.arguments as int;
        return SmoothRoute(
          settings: settings,
          type: TransitionType.fadeSlideUp,
          page: GodDetailsView(godIndex: godIndex),
        );

      case AppRoutes.egyptianHistoryView:
        return SmoothRoute(
          settings: settings,
          type: TransitionType.fadeSlideUp,
          page: const EgyptianHistoryView(),
        );

      case AppRoutes.mythologyView:
        return SmoothRoute(
          settings: settings,
          type: TransitionType.fadeSlideUp,
          page: const MythologyView(),
        );

      case AppRoutes.editProfileView:
        return SmoothRoute(
          settings: settings,
          type: TransitionType.fadeSlideRight,
          page: const EditProfileView(),
        );

      default:
        return SmoothRoute(
          settings: settings,
          type: TransitionType.fade,
          page: Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
