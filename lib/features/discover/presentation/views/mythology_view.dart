import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/routing/routes.dart';
import 'package:echo_explorer/core/widgets/custom_bottom_nav_bar.dart';
import 'package:echo_explorer/core/widgets/custom_floating_action_button.dart';
import 'package:echo_explorer/core/widgets/custom_glass_app_bar.dart';
import 'package:echo_explorer/core/widgets/custom_glass_drawer.dart';
import 'package:echo_explorer/core/widgets/custom_section_button.dart';
import 'package:echo_explorer/core/widgets/entrance_animation.dart';
import 'package:echo_explorer/features/discover/data/gods_data.dart';
import 'package:echo_explorer/features/home/presentation/cubit/features_cubit.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MythologyView extends StatelessWidget {
  const MythologyView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final godsList = GodsData.getGodsData(context);

    return Scaffold(
      drawer: CustomGlassDrawer(
        currentFeature: AppStrings.discoverFeature.key,
        onTap: (featureKey) {
          Navigator.popUntil(context, (route) => route.isFirst);
          context.read<FeaturesCubit>().changeFeature(featureName: featureKey);
        },
      ),
      drawerEnableOpenDragGesture: false,
      drawerBarrierDismissible: true,
      backgroundColor: AppColors.of(context).background,

      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.only(
                        top: 70.h,
                        left: 16.w,
                        right: 16.w,
                        bottom: 100.h,
                      ),
                      children: [
                        EntranceAnimation(
                          delay: Duration.zero,
                          child: CustomSectionButton(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.godDetailsView,
                                arguments: 0,
                              );
                            },
                            image: godsList[0].coverImagePath,
                            title: godsList[0].title,
                          ),
                        ),

                        GridView.builder(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16.w,
                                mainAxisSpacing: 16.h,
                                childAspectRatio: 170 / 224,
                              ),
                          itemCount: godsList.length - 1,
                          itemBuilder: (context, index) {
                            return EntranceAnimation(
                              delay: Duration(milliseconds: (index + 1) * 80),
                              child: CustomSectionButton(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.godDetailsView,
                                    arguments: index + 1,
                                  );
                                },
                                image: godsList[index + 1].coverImagePath,
                                title: godsList[index + 1].title,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomGlassAppBar(
              previousState: AppStrings.discoverFeature.key,
              title: l10n.discoverMythologyTitle,
              onPressed: () => Navigator.pop(context),
              rtlAware: true,
              trailingBuilder: (ctx) => IconButton(
                icon: Icon(
                  Icons.menu,
                  color: AppColors.of(context).footer,
                  size: 30.r,
                ),
                onPressed: () {
                  Scaffold.of(ctx).openDrawer();
                },
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomBottomNavBar(
              currentFeature: AppStrings.discoverFeature.key,
              onTap: (featureName) {
                context.read<FeaturesCubit>().changeFeature(
                  featureName: featureName,
                );
                Navigator.pop(context);
              },
            ),
          ),

          Positioned(
            bottom: 35.h,
            left: 0,
            right: 0,
            child: Center(
              child: CustomFloatingActionButton(
                onPressed: () {
                  context.read<FeaturesCubit>().changeFeature(
                    featureName: AppStrings.scanFeature.key,
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
