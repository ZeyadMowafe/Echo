import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:echo_explorer/core/constants/app_images.dart';
import 'package:echo_explorer/features/discover/data/models/god_model.dart';

class GodsData {
  static List<GodModel> getGodsData(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return [
      GodModel(
        title: l10n.god1Title,
        description: l10n.god1Desc,
        coverImagePath: AppImages.mythology.theChroniclesCover,
        bgImagePath: AppImages.mythology.theChroniclesBackground,
      ),
      GodModel(
        title: l10n.god2Title,
        subtitle: l10n.god2Subtitle,
        description: l10n.god2Desc,
        coverImagePath: AppImages.gods.atumBackGround,
        bgImagePath: AppImages.gods.atumBackGround,
      ),
      GodModel(
        title: l10n.god3Title,
        subtitle: l10n.god3Subtitle,
        description: l10n.god3Desc,
        coverImagePath: AppImages.gods.osirisBackGround,
        bgImagePath: AppImages.gods.osirisBackGround,
      ),
      GodModel(
        title: l10n.god4Title,
        subtitle: l10n.god4Subtitle,
        description: l10n.god4Desc,
        coverImagePath: AppImages.gods.isisBackGround,
        bgImagePath: AppImages.gods.isisBackGround,
      ),
      GodModel(
        title: l10n.god5Title,
        subtitle: l10n.god5Subtitle,
        description: l10n.god5Desc,
        coverImagePath: AppImages.gods.sethBackGround,
        bgImagePath: AppImages.gods.sethBackGround,
      ),
      GodModel(
        title: l10n.god6Title,
        subtitle: l10n.god6Subtitle,
        description: l10n.god6Desc,
        coverImagePath: AppImages.gods.horusBackGround,
        bgImagePath: AppImages.gods.horusBackGround,
      ),
      GodModel(
        title: l10n.god7Title,
        subtitle: l10n.god7Subtitle,
        description: l10n.god7Desc,
        coverImagePath: AppImages.gods.raBackGround,
        bgImagePath: AppImages.gods.raBackGround,
      ),
      GodModel(
        title: l10n.god8Title,
        subtitle: l10n.god8Subtitle,
        description: l10n.god8Desc,
        coverImagePath: AppImages.gods.amunBackGround,
        bgImagePath: AppImages.gods.amunBackGround,
      ),
      GodModel(
        title: l10n.god9Title,
        subtitle: l10n.god9Subtitle,
        description: l10n.god9Desc,
        coverImagePath: AppImages.gods.anubisBackGround,
        bgImagePath: AppImages.gods.anubisBackGround,
      ),
      GodModel(
        title: l10n.god10Title,
        subtitle: l10n.god10Subtitle,
        description: l10n.god10Desc,
        coverImagePath: AppImages.gods.thothBackGround,
        bgImagePath: AppImages.gods.thothBackGround,
      ),
      GodModel(
        title: l10n.god11Title,
        subtitle: l10n.god11Subtitle,
        description: l10n.god11Desc,
        coverImagePath: AppImages.gods.ptahBackGround,
        bgImagePath: AppImages.gods.ptahBackGround,
      ),
      GodModel(
        title: l10n.god12Title,
        description: l10n.god12Desc,
        coverImagePath: AppImages.gods.sekhmetBackGround,
        bgImagePath: AppImages.gods.sekhmetBackGround,
      ),
      GodModel(
        title: l10n.god13Title,
        description: l10n.god13Desc,
        coverImagePath: AppImages.gods.bastetBackGround,
        bgImagePath: AppImages.gods.bastetBackGround,
      ),
      GodModel(
        title: l10n.god14Title,
        description: l10n.god14Desc,
        coverImagePath: AppImages.gods.hathorBackGround,
        bgImagePath: AppImages.gods.hathorBackGround,
      ),
      GodModel(
        title: l10n.god15Title,
        description: l10n.god15Desc,
        coverImagePath: AppImages.gods.neithBackGround,
        bgImagePath: AppImages.gods.neithBackGround,
      ),
    ];
  }
}