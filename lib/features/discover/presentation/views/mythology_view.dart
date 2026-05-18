import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/routing/routes.dart';
import 'package:echo_explorer/core/widgets/custom_bottom_nav_bar.dart';
import 'package:echo_explorer/core/widgets/custom_floating_action_button.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:echo_explorer/core/widgets/custom_glass_drawer.dart';
import 'package:echo_explorer/core/widgets/custom_section_button.dart';
import 'package:echo_explorer/features/discover/data/gods_data.dart';
import 'package:echo_explorer/features/home/presentation/view_model/features_cubit.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MythologyView extends StatelessWidget {
  const MythologyView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final godsList = GodsData.getGodsData(context);

    return Scaffold(
      endDrawer: CustomGlassDrawer(
        currentFeature: AppStrings.discoverFeature.key,
        onTap: (featureKey) {
          context.read<FeaturesCubit>().changeFeature(featureName: featureKey);
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
      drawerEnableOpenDragGesture: false,
      drawerBarrierDismissible: false,
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
                      padding: const EdgeInsets.only(
                        top: 70,
                        left: 16,
                        right: 16,
                        bottom: 100,
                      ),
                      children: [
                        CustomSectionButton(
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

                        GridView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 170 / 224, 
                              ),
                          itemCount: godsList.length - 1,
                          itemBuilder: (context, index) {
                            return CustomSectionButton(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.godDetailsView,
                                  arguments: index + 1,
                                );
                              },
                              image: godsList[index + 1].coverImagePath,
                              title: godsList[index + 1].title,
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
            child: CustomGlassContainer(
              color: AppColors.of(context).discoverAppBar.withOpacity(0.25),
              gradient: LinearGradient(
                colors: [
                  AppColors.of(context).discoverAppBar.withOpacity(0.30),
                  AppColors.of(context).discoverAppBar.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderColor: AppColors.of(context).discoverAppBar.withOpacity(0.05),
              padding: const EdgeInsets.only(
                top: 6,
                bottom: 6,
                left: 20,
                right: 20,
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  spacing: 8,
                  children: [
                    CustomGlassContainer(
                      width: 34,
                      height: 34,
                      borderRadius: BorderRadius.circular(50),
                      borderColor: AppColors.cffffff.withOpacity(0.10),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      color: AppColors.cffffff.withOpacity(0.10),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.cffffff.withOpacity(0.20),
                          AppColors.cffffff.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      child: CustomGlassContainer(
                        width: 34,
                        height: 34,
                        color: AppColors.cffffff.withOpacity(0.25),
                        borderColor: AppColors.cffffff.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(50),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.cffffff.withOpacity(0.30),
                            AppColors.cffffff.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        child: IconButton(
                          alignment: Alignment.center,
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Directionality.of(context) == TextDirection.rtl
                                ? Icons.arrow_forward_rounded
                                : Icons.arrow_back_rounded,
                            color: AppColors.of(context).footer,
                            size: 22,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    Text(
                      l10n.discoverMythologyTitle, 
                      style: TextStyle(
                        color: AppColors.of(context).footer,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Builder(
                      builder: (innerContext) {
                        return IconButton(
                          icon: Icon(
                            Icons.menu,
                            color: AppColors.of(context).footer,
                            size: 30,
                          ),
                          onPressed: () {
                            Scaffold.of(innerContext).openEndDrawer();
                          },
                        );
                      },
                    ),
                  ],
                ),
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
            bottom: 60,
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