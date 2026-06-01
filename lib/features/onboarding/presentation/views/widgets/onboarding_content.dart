import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/hive/cache_helper.dart';
import 'package:echo_explorer/core/routing/routes.dart';
import 'package:echo_explorer/features/onboarding/data/onboarding_data.dart';
import 'package:echo_explorer/features/onboarding/presentation/views/widgets/glass_card.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingContent extends StatelessWidget {
  const OnboardingContent({
    super.key,
    required this.index,
    required this.onTapNext,
  });
  final int index;
  final void Function()? onTapNext;

  @override
  Widget build(BuildContext context) {
    final onboardList = OnboardingData.getOnboardData(context);
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          onboardList[index].imageBG,
          cacheWidth: 1080,
          fit: BoxFit.cover,
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
        ),
        PositionedDirectional(
          top: 52.h,
          end: 26.w,
          child: InkWell(
            onTap: () {
              CacheHelper.putData(
                key: AppStrings.hiveKeys.cacheHelper.isOnboardingCompleted,
                value: true,
              );
              Navigator.pushReplacementNamed(context, AppRoutes.authView);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.onboardingSkip, 
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Icon(
                  Directionality.of(context) == TextDirection.rtl 
                      ? Icons.arrow_back_ios 
                      : Icons.arrow_forward_ios, 
                  color: Colors.white, 
                  size: 20.r
                ),
              ],
            ),
          ),
        ),
        GlassCard(index: index, onTapNext: onTapNext),
      ],
    );
  }
}