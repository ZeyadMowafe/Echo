import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:echo_explorer/core/constants/app_images.dart';
import 'package:echo_explorer/features/discover/data/models/era_model.dart';

class ErasData {
  static List<EraModel> getErasData(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return [
      EraModel(
        title: l10n.era1Title,
        description: l10n.era1Desc,
        imagePath: AppImages.egyptianHistory.ehPre,
      ),
      EraModel(
        title: l10n.era2Title,
        description: l10n.era2Desc,
        imagePath: AppImages.egyptianHistory.ehOld,
        isRightAligned: true,
      ),
      EraModel(
        title: l10n.era3Title,
        description: l10n.era3Desc,
      ),
      EraModel(
        title: l10n.era4Title,
        description: l10n.era4Desc,
        imagePath: AppImages.egyptianHistory.ehMiddle,
        isRightAligned: true,
      ),
      EraModel(
        title: l10n.era5Title,
        description: l10n.era5Desc,
      ),
      EraModel(
        title: l10n.era6Title,
        description: l10n.era6Desc,
        imagePath: AppImages.egyptianHistory.ehNew,
        isRightAligned: true,
      ),
      EraModel(
        title: l10n.era7Title,
        description: l10n.era7Desc,
        imagePath: AppImages.egyptianHistory.ehThird,
      ),
      EraModel(
        title: l10n.era8Title,
        description: l10n.era8Desc,
        imagePath: AppImages.egyptianHistory.ehLate,
        isRightAligned: true,
      ),
      EraModel(
        title: l10n.era9Title,
        description: l10n.era9Desc,
        imagePath: AppImages.egyptianHistory.ehGreek,
      ),
    ];
  }
}