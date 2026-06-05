import 'dart:convert';
import 'dart:io';

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:echo_explorer/core/constants/app_colors.dart';

import 'package:echo_explorer/core/constants/app_strings.dart';

import 'package:echo_explorer/core/routing/app_transitions.dart';

import 'package:echo_explorer/core/widgets/custom_bottom_nav_bar.dart';

import 'package:echo_explorer/core/widgets/custom_floating_action_button.dart';

import 'package:echo_explorer/core/widgets/custom_glass_drawer.dart';

import 'package:echo_explorer/features/chat/presentation/views/chat_view.dart';

import 'package:echo_explorer/core/constants/app_dimensions.dart';
import 'package:echo_explorer/core/widgets/custom_glass_back_button.dart';

import 'package:echo_explorer/features/home/presentation/cubit/features_cubit.dart';

import 'package:echo_explorer/features/scanner/data/models/scan_result_args.dart';

import 'package:echo_explorer/features/scanner/domain/entities/scan_response_entity.dart';

import 'package:echo_explorer/features/scanner/presentation/cubit/scan_cubit.dart';

import 'package:echo_explorer/core/network/api_constants.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:gap/gap.dart';

class DetailsView extends StatefulWidget {
  final ScanResultArgs args;
  const DetailsView({super.key, required this.args});

  @override
  State<DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends State<DetailsView> {
  bool _showTranslation = false;
  bool _showToast = false;
  bool _toastIsFavorited = false;
  bool _isFavorited = false;

  ScanResponseEntity get _result => widget.args.result;
  String? get _imagePath => widget.args.imagePath;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.args.isFavorited;
    _logResponse();
  }

  void _logResponse() {
    print('╔═══════════════════════════════════════════');
    print('║  📄 DetailsView - Full Response Data');
    print('╠═══════════════════════════════════════════');
    print('║ scanLogId: ${_result.scanLogId}');
    print('║ imagePath: $_imagePath');
    print('║ isFavorited: $_isFavorited');
    print('║');
    print('║ ── Artifact ──');
    print('║ name: ${_result.artifact.name}');
    print('║ description: ${_result.artifact.description}');
    print('║ era: ${_result.artifact.era}');
    print('║ material: ${_result.artifact.material}');
    print('║ category: ${_result.artifact.category}');
    print('║ type: ${_result.artifact.type}');
    print('║ imageUrl: ${_result.artifact.imageUrl}');
    print('║ isPrimaryModel: ${_result.artifact.isPrimaryModel}');
    print('║ artifactModelId: ${_result.artifact.artifactModelId}');
    print('║');
    print('║ ── Hieroglyphs ──');
    print('║ detected: ${_result.hieroglyphs?.detected}');
    print('║ translation: ${_result.hieroglyphs?.translation}');
    print('║ translationMethod: ${_result.hieroglyphs?.translationMethod}');
    print('║ totalLines: ${_result.hieroglyphs?.totalLines}');
    print('║ totalGlyphs: ${_result.hieroglyphs?.totalGlyphs}');
    print('║ cartoucheCount: ${_result.hieroglyphs?.cartoucheCount}');
    print('║ royalNames: ${_result.hieroglyphs?.royalNames}');
    print('╚═══════════════════════════════════════════');
  }

  void _showFavoriteToast() {
    _toastIsFavorited = _isFavorited;
    setState(() => _showToast = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showToast = false);
    });
  }

  void _toggleFavorite() {
    final scanLogId = _result.scanLogId;
    if (scanLogId == null) return;
    setState(() => _isFavorited = !_isFavorited);
    context.read<ScanCubit>().toggleScanResultFavorite(scanLogId);
    _showFavoriteToast();
  }

  Widget _buildTopBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppDimensions.glassSigma,
          sigmaY: AppDimensions.glassSigma,
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.of(context).glassBase.withValues(alpha: 0.10),
            gradient: LinearGradient(
              colors: [
                AppColors.of(context).glassBase.withValues(alpha: 0.15),
                AppColors.of(context).glassBase.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(
              bottom: BorderSide(
                color: AppColors.of(context).glassBase.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 6.h,
            bottom: 6.h,
            left: 20.w,
            right: 20.w,
          ),
          child: Row(
            spacing: 8.w,
            children: [
              CustomGlassBackButton(
                onPressed: () => Navigator.pop(context),
                rtlAware: true,
              ),
              Expanded(
                child: Text(
                  l10n.detailsTitle,
                  style: TextStyle(
                    color: AppColors.of(context).footer,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () => Scaffold.of(ctx).openDrawer(),
                  child: Icon(
                    Icons.menu_rounded,
                    size: 28.r,
                    color: AppColors.of(context).footer.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasScanLogId = _result.scanLogId != null;

    return Scaffold(
      backgroundColor: AppColors.of(context, listen: false).background,
      drawerScrimColor: Colors.transparent,
      drawer: CustomGlassDrawer(
        currentFeature: AppStrings.scanFeature.key,
        onTap: (featureName) {
          final cubit = context.read<FeaturesCubit>();
          Navigator.of(context).popUntil((route) => route.isFirst);
          cubit.changeFeature(featureName: featureName);
        },
      ),
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () {
          final cubit = context.read<FeaturesCubit>();
          Navigator.of(context).popUntil((route) => route.isFirst);
          cubit.changeFeature(featureName: AppStrings.scanFeature.key);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        currentFeature: AppStrings.scanFeature.key,
        onTap: (featureName) {
          final cubit = context.read<FeaturesCubit>();
          Navigator.of(context).popUntil((route) => route.isFirst);
          cubit.changeFeature(featureName: featureName);
        },
      ),
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 19.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gap(32.h),
                      // Action bar: Reveal Translation + Heart
                      SizedBox(
                        width: double.infinity,
                        height: 32.h,
                        child: Row(
                          children: [
                            if (_result.hieroglyphs?.detected == true &&
                                _result.hieroglyphs?.translation != null)
                              GestureDetector(
                                onTap: () => setState(
                                  () => _showTranslation = !_showTranslation,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24.r),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 15,
                                      sigmaY: 15,
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          24.r,
                                        ),
                                        border: Border.all(
                                          color: AppColors.of(
                                            context,
                                          ).glassBase.withValues(alpha: 0.1),
                                        ),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            AppColors.of(
                                              context,
                                            ).glassBase.withValues(alpha: 0.05),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _showTranslation
                                                ? Icons.format_list_bulleted
                                                : Icons.visibility_rounded,
                                            color: AppColors.of(context).footer,
                                            size: 12.r,
                                          ),
                                          Gap(4.w),
                                          Text(
                                            _showTranslation
                                                ? l10n.detailsAboutThisArtifact
                                                : l10n.detailsRevealTranslation,
                                            style: TextStyle(
                                              color: AppColors.of(
                                                context,
                                              ).footer,
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            const Spacer(),
                            GestureDetector(
                              onTap: _toggleFavorite,
                              child: Icon(
                                hasScanLogId && _isFavorited
                                    ? Icons.favorite
                                    : Icons.favorite_border_rounded,
                                size: 24.r,
                                color: hasScanLogId && _isFavorited
                                    ? Colors.redAccent
                                    : AppColors.of(
                                        context,
                                      ).footer.withValues(alpha: 0.6),
                              ),
                            ),
                            Gap(10.w),
                          ],
                        ),
                      ),
                      Gap(32.h),
                      // Product image
                      if (_result.artifact.imageUrl != null)
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24.r),
                            child: CachedNetworkImage(
                              imageUrl: _result.artifact.imageUrl!.startsWith(
                                    'http',
                                  )
                                  ? _result.artifact.imageUrl!
                                  : '${ApiConstants.baseUrl}${_result.artifact.imageUrl!}',
                              width: 150.w,
                              height: 220.h,
                              fit: BoxFit.contain,
                              errorWidget: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        )
                      else if (_imagePath != null)
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24.r),
                            child: Image.file(
                              File(_imagePath!),
                              cacheWidth: 400,
                              width: 150.w,
                              height: 220.h,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      // Translation text (when toggled)
                      if (_showTranslation &&
                          _result.hieroglyphs?.translation != null) ...[
                        Gap(32.h),
                        Text(
                          l10n.detailsTranslationReveals,
                          style: TextStyle(
                            color: AppColors.of(context).footer,
                            fontSize: 20.sp,
                            height: 1.2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Gap(12.h),
                        Text(
                          _result.hieroglyphs!.translation!,
                          style: TextStyle(
                            color: AppColors.of(
                              context,
                            ).footer.withValues(alpha: 0.85),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                      ],
                      if (!_showTranslation) ...[
                        Gap(32.h),
                        // Artifact name
                        Text(
                          _result.artifact.name ?? l10n.detailsUnknownArtifact,
                          style: TextStyle(
                            color: AppColors.of(context).footer,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        // Artifact info as comma-separated text
                        Builder(
                          builder: (context) {
                            final parts = <String>[];
                            if (_result.artifact.era != null) {
                              parts.add(_result.artifact.era!);
                            }
                            if (_result.artifact.material != null) {
                              parts.add(_result.artifact.material!);
                            }
                            if (_result.artifact.category != null) {
                              parts.add(_result.artifact.category!);
                            }
                            if (_result.artifact.type != null) {
                              parts.add(_result.artifact.type!);
                            }
                            if (parts.isEmpty) return const SizedBox.shrink();
                            return Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text(
                                parts.join('  |  '),
                                style: TextStyle(
                                  color: AppColors.of(context).footer,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                      if (!_showTranslation) ...[
                        Gap(32.h),
                        // Divider
                        Container(
                          width: 337.w,
                          height: 0,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: AppColors.of(
                                  context,
                                ).footer.withValues(alpha: 0.15),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        Gap(32.h),
                        Text(
                          l10n.detailsDescription,
                          style: TextStyle(
                            color: AppColors.of(context).footer,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Gap(12.h),
                        // Description
                        Text(
                          _result.artifact.description ?? '',
                          style: TextStyle(
                            color: AppColors.of(context).footer,
                            fontSize: 16.sp,
                            height: 1.2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                      if (_result.artifact.isPrimaryModel &&
                          _result.artifact.artifactModelId != null) ...[
                        Gap(32.h),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                SmoothRoute(
                                  type: TransitionType.fadeSlideUp,
                                  page: ChatView(
                                    artifactId:
                                        _result.artifact.artifactModelId ?? '',
                                    artifactName:
                                        _result.artifact.name ??
                                        _result.artifact.artifactModelId ??
                                        '',
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24.r),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 15,
                                  sigmaY: 15,
                                ),
                                child: Container(
                                  width: 335.w,
                                  height: 43.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24.r),
                                    border: Border.all(
                                      color: AppColors.of(
                                        context,
                                      ).glassBase.withValues(alpha: 0.15),
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColors.of(
                                          context,
                                        ).glassBase.withValues(alpha: 0.02),
                                        AppColors.of(
                                          context,
                                        ).glassBase.withValues(alpha: 0.02),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      l10n.detailsChatWithMe,
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.of(context).footer,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      Gap(40.h),
                    ],
                  ),
                ),
                if (_showToast)
                  Positioned(
                    top: 1.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 300.w,
                        padding: EdgeInsets.symmetric(
                          vertical: 10.h,
                          horizontal: 16.w,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.of(
                            context,
                          ).background.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _toastIsFavorited
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 18.r,
                                color: AppColors.of(context).footer,
                              ),
                              Gap(10.w),
                              Text(
                                _toastIsFavorited
                                    ? l10n.scanAddedToFavorites
                                    : l10n.scanRemovedFromFavorites,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15.sp,
                                  color: AppColors.of(context).footer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
