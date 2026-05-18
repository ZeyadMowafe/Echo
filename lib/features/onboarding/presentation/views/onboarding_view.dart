import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/hive/cache_helper.dart';
import 'package:echo_explorer/core/routing/routes.dart';
import 'package:echo_explorer/features/onboarding/data/onboarding_data.dart';
import 'package:echo_explorer/features/onboarding/presentation/views/widgets/onboarding_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late PageController _pageController;
  int _pageIndex = 0;
  
  void onTapNext() {
    if (_pageIndex < OnboardingData.getOnboardData(context).length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    } else {
      CacheHelper.putData(
        key: AppStrings.hiveKeys.cacheHelper.isOnboardingCompleted,
        value: true,
      );
      Navigator.pushReplacementNamed(context, AppRoutes.authView);
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: OnboardingData.getOnboardData(context).length,
        controller: _pageController,
        onPageChanged: (int index) {
          setState(() {
            _pageIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double pageOffset = 0.0;
              if (_pageController.position.haveDimensions) {
                pageOffset = _pageController.page! - index;
              }
              double opacity = (1 - pageOffset.abs()).clamp(0.0, 1.0);
              double screenWidth = MediaQuery.of(context).size.width;
              double dx = pageOffset * screenWidth;
              return Transform.translate(
                offset: Offset(dx, 0),
                child: Opacity(opacity: opacity, child: child),
              );
            },
            child: OnboardingContent(index: index, onTapNext: onTapNext),
          );
        },
      ),
    );
  }
}