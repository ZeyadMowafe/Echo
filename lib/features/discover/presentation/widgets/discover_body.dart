import 'package:echo_explorer/core/constants/app_images.dart';
import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/routing/routes.dart';
import 'package:echo_explorer/core/widgets/entrance_animation.dart';
import 'package:echo_explorer/features/discover/data/models/section_card_model.dart';
import 'package:echo_explorer/features/discover/presentation/widgets/custom_discover_app_bar.dart';
import 'package:echo_explorer/features/discover/presentation/widgets/custom_section_card.dart';
import 'package:echo_explorer/features/home/presentation/cubit/features_cubit.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiscoverBody extends StatelessWidget {
  const DiscoverBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        CustomDiscoverAppBar(
          previousState: AppStrings.homeFeature.key,
          title: l10n.discoverTitle,
          onPressed: () {
            context.read<FeaturesCubit>().changeFeature(featureName: AppStrings.homeFeature.key);
          },
        ),
        Expanded(
          child: EntranceAnimation(
            delay: const Duration(milliseconds: 100),
            child: CustomSectionCard(
              sectionCardModel: SectionCardModel(
                image: AppImages.egyptianHistory.egyptionHistoryCover,
                title: l10n.discoverHistoryTitle,
                buttonText: l10n.discoverHistoryButton,
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.egyptianHistoryView);
              },
            ),
          ),
        ),
        Expanded(
          child: EntranceAnimation(
            delay: const Duration(milliseconds: 200),
            child: CustomSectionCard(
              sectionCardModel: SectionCardModel(
                image: AppImages.mythology.mythologyCover,
                title: l10n.discoverMythologyTitle,
                buttonText: l10n.discoverMythologyButton,
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.mythologyView);
              },
            ),
          ),
        ),
      ],
    );
  }
}