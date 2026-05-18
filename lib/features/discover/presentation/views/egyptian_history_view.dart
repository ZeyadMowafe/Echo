import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/widgets/custom_bottom_nav_bar.dart';
import 'package:echo_explorer/core/widgets/custom_floating_action_button.dart';
import 'package:echo_explorer/features/discover/data/eras_data.dart';
import 'package:echo_explorer/features/discover/presentation/widgets/custom_discover_app_bar.dart';
import 'package:echo_explorer/features/discover/presentation/widgets/custom_era_time_line_card.dart';
import 'package:echo_explorer/features/home/presentation/view_model/features_cubit.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EgyptianHistoryView extends StatelessWidget {
  const EgyptianHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final erasDataList = ErasData.getErasData(context);

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () {
          context.read<FeaturesCubit>().changeFeature(
            featureName: AppStrings.scanFeature.key,
          );
          Navigator.pop(context); 
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        currentFeature: AppStrings.discoverFeature.key, 
        onTap: (featureName) {
          context.read<FeaturesCubit>().changeFeature(
            featureName: featureName,
          );
          Navigator.pop(context); 
        },
      ),
      body: Column(
        children: [
          CustomDiscoverAppBar(
            previousState: AppStrings.discoverFeature.key,
            title: l10n.discoverHistoryTitle, 
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 100, bottom: 32), 
              itemCount: erasDataList.length, 
              itemBuilder: (context, index) {
                return EraTimelineCard(
                  title: erasDataList[index].title,
                  description: erasDataList[index].description,
                  imagePath: erasDataList[index].imagePath, 
                  isImageRight: erasDataList[index].isRightAligned, 
                  isLast: index == erasDataList.length - 1, 
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}