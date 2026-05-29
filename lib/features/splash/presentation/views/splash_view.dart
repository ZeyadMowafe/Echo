import 'package:echo_explorer/core/hive/cache_helper.dart';
import 'package:echo_explorer/core/routing/app_transitions.dart';
import 'package:echo_explorer/features/home/presentation/views/home_view.dart';
import 'package:echo_explorer/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final target = CacheHelper.isOnboardingCompleted
        ? const HomeView()
        : const OnboardingView();
    Navigator.pushReplacement(
      context,
      SmoothRoute(
        type: TransitionType.fade,
        page: target,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1215), Color(0xFF1C252A)],
        ),
      ),
      child: Center(
        child: Image.asset(
          'assets/images/splash_icon_dark.png',
          width: 200.w,
          height: 200.h,
        ),
      ),
    );
  }
}
