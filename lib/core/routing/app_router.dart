import 'package:echo_explorer/core/hive/cache_helper.dart';
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
import 'package:flutter/material.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (context) => CacheHelper.isOnboardingCompleted
              ? const HomeView()
              : const OnboardingView(),
        );
      case AppRoutes.homeView:
        return MaterialPageRoute(builder: (context) => const HomeView());
      case AppRoutes.onboardingView:
        return MaterialPageRoute(builder: (context) => const OnboardingView());

      case AppRoutes.authView: 
        return MaterialPageRoute(builder: (context) => const AuthView());

      case AppRoutes.chatView:
        final chatArgs = settings.arguments;
        if (chatArgs is Map<String, dynamic>) {
          print('=== AppRouter: chatView with args: $chatArgs ===');
          return MaterialPageRoute(
            builder: (context) => ChatView(
              artifactId: chatArgs['artifactId'] as String?,
              artifactName: chatArgs['artifactName'] as String?,
            ),
          );
        }
        print('=== AppRouter: chatView with NO args (args type: ${chatArgs?.runtimeType}) ===');
        return MaterialPageRoute(builder: (context) => const ChatView());
      case AppRoutes.scanView:
        return MaterialPageRoute(builder: (context) => const ScannerView());
      case AppRoutes.settingsView:
        return MaterialPageRoute(builder: (context) => const SettingsView());
      case AppRoutes.godDetailsView:
        final godIndex = settings.arguments as int;
        return MaterialPageRoute(
          builder: (context) => GodDetailsView(godIndex: godIndex),
        );
      case AppRoutes.egyptianHistoryView:
        return MaterialPageRoute(
          builder: (context) => const EgyptianHistoryView(),
        );
      case AppRoutes.mythologyView:
        return MaterialPageRoute(builder: (context) => const MythologyView());
      case AppRoutes.editProfileView:
        return MaterialPageRoute(builder: (context) => const EditProfileView());
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
