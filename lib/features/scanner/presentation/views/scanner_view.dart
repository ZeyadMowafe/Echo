import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/di/injection_container.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/core/routing/app_transitions.dart';
import 'package:echo_explorer/core/widgets/app_loading.dart';
import 'package:echo_explorer/core/widgets/custom_glass_back_button.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:echo_explorer/core/widgets/custom_glass_drawer.dart';
import 'package:echo_explorer/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:echo_explorer/features/auth/presentation/widgets/auth_sheet_helper.dart';
import 'package:echo_explorer/features/chat/presentation/views/chat_view.dart';
import 'package:echo_explorer/features/home/presentation/cubit/features_cubit.dart';
import 'package:echo_explorer/features/scanner/data/models/scan_result_args.dart';
import 'package:echo_explorer/features/scanner/domain/entities/scan_artifact_entity.dart';
import 'package:echo_explorer/features/scanner/domain/entities/scan_response_entity.dart';
import 'package:echo_explorer/features/scanner/presentation/cubit/scan_cubit.dart';
import 'package:echo_explorer/features/scanner/presentation/views/camera_scanner_view.dart';
import 'package:echo_explorer/features/scanner/presentation/views/details_view.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class ScannerView extends StatelessWidget {
  const ScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => sl<ScanCubit>(), child: _ScannerBody());
  }
}

class _ScannerBody extends StatefulWidget {
  @override
  State<_ScannerBody> createState() => _ScannerBodyState();
}

class _ScannerBodyState extends State<_ScannerBody> {
  final _picker = ImagePicker();
  bool _showTranslation = false;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: context.watch<ScanCubit>().state is ScanInitial,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.read<ScanCubit>().clearResult();
      },
      child: Scaffold(
        backgroundColor: AppColors.of(context).background,
        drawerScrimColor: Colors.transparent,
        drawer: CustomGlassDrawer(
          currentFeature: AppStrings.scanFeature.key,
          onTap: (featureName) {
            final cubit = context.read<FeaturesCubit>();
            Navigator.of(context).popUntil((route) => route.isFirst);
            cubit.changeFeature(featureName: featureName);
          },
        ),
        body: Stack(
          children: [
            BlocBuilder<ScanCubit, ScanState>(
              buildWhen: (previous, current) =>
                  previous.runtimeType != current.runtimeType,
              builder: (context, state) {
                if (state is ScanInitial) return _buildHome(context);
                if (state is ScanImagePicked)
                  return _buildPreview(context, imagePath: state.imagePath);
                if (state is ScanLoading)
                  return _buildPreview(
                    context,
                    imagePath: context.read<ScanCubit>().currentImagePath ?? '',
                    isLoading: true,
                  );
                if (state is ScanResultLoaded)
                  return _buildPreview(
                    context,
                    imagePath: state.imagePath ?? '',
                    result: state,
                    showTranslation: _showTranslation,
                    onToggleTranslation: () =>
                        setState(() => _showTranslation = !_showTranslation),
                  );
                if (state is ScanAnchored)
                  return _buildPreview(
                    context,
                    imagePath: state.imagePath ?? '',
                    result: ScanResultLoaded(
                      result: state.result,
                      imagePath: state.imagePath,
                      isFavorited: state.isFavorited,
                    ),
                    showTranslation: _showTranslation,
                    onToggleTranslation: () =>
                        setState(() => _showTranslation = !_showTranslation),
                  );
                if (state is ScanFilterRejected)
                  return _buildFilterRejected(context, state);
                if (state is ScanNoArtifactDetected)
                  return _buildNoArtifactDetected(context);
                if (state is ScanError) return _buildError(context, state);
                return _buildHome(context);
              },
            ),
            RepaintBoundary(
              child: PositionedDirectional(
                start: 16.w,
                top: MediaQuery.of(context).padding.top + 6.h,
                child: CustomGlassBackButton(
                  iconColor: AppColors.of(context).footer,
                  onPressed: () {
                    final state = context.read<ScanCubit>().state;
                    if (state is! ScanInitial) {
                      context.read<ScanCubit>().clearResult();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ),
            RepaintBoundary(
              child: PositionedDirectional(
                end: 16.w,
                top: MediaQuery.of(context).padding.top + 6.h,
                child: Builder(
                  builder: (ctx) => GestureDetector(
                    onTap: () => Scaffold.of(ctx).openDrawer(),
                    child: Icon(
                      Icons.menu_rounded,
                      size: 28.r,
                      color: AppColors.of(
                        context,
                      ).footer.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHome(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenUtils.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(ScreenUtils.md),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.document_scanner_outlined,
                size: ScreenUtils.iconXl,
                color: AppColors.secondary,
              ),
            ),
            Gap(ScreenUtils.lg),
            Text(
              l10n.scanTitle,
              style: TextStyle(
                color: AppColors.of(context).footer,
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(ScreenUtils.sm),
            Text(
              l10n.scanSubtitle,
              style: TextStyle(
                color: AppColors.of(context).footer.withValues(alpha: 0.5),
                fontSize: 14.sp,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(ScreenUtils.xxl),
            _GlassSelectionCard(
              icon: Icons.camera_alt_rounded,
              label: l10n.scanTakePhoto,
              onTap: () => Navigator.push(
                context,
                SmoothRoute(
                  type: TransitionType.slideUp,
                  page: BlocProvider.value(
                    value: context.read<ScanCubit>(),
                    child: const CameraScannerView(),
                  ),
                ),
              ),
            ),
            Gap(ScreenUtils.md),
            _GlassSelectionCard(
              icon: Icons.photo_library_outlined,
              label: l10n.scanPickGallery,
              onTap: () => _pickImage(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source);
      if (file != null && context.mounted) {
        context.read<ScanCubit>().setImagePath(file.path);
        await Future.delayed(const Duration(seconds: 3));
        if (context.mounted) {
          context.read<ScanCubit>().analyzeImage();
        }
      }
    } on PlatformException catch (_) {
      // Image picker was dismissed or already active — ignore
    }
  }

  Future<void> _saveToFavorites(BuildContext context, String scanLogId) async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) {
      showAuthSheet(context, '');
      return;
    }
    final cubit = context.read<ScanCubit>();
    final wasFavorited =
        cubit.state is ScanResultLoaded &&
        (cubit.state as ScanResultLoaded).isFavorited;
    final success = await cubit.toggleScanResultFavorite(scanLogId);
    if (!context.mounted) return;
    if (success) {
      final l10n = AppLocalizations.of(context)!;
      if (!wasFavorited) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.favorite, color: Colors.redAccent, size: 20.r),
                Gap(12.w),
                Text(
                  l10n.scanAddedToFavorites,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: AppColors.of(context).surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            duration: const Duration(milliseconds: 1200),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 800));
        if (context.mounted) Navigator.pop(context, 'navigate_to_favorites');
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.favorite_border, color: Colors.grey, size: 20.r),
                Gap(12.w),
                Text(
                  l10n.scanRemovedFromFavorites,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: AppColors.of(context).surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            duration: const Duration(milliseconds: 1200),
          ),
        );
      }
    }
  }

  Widget _buildPreview(
    BuildContext context, {
    required String imagePath,
    bool isLoading = false,
    ScanResultLoaded? result,
    bool showTranslation = false,
    VoidCallback? onToggleTranslation,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final backButton = PositionedDirectional(
      start: 16.w,
      top: 8.h,
      child: CustomGlassBackButton(
        iconColor: Colors.white,
        onPressed: () => context.read<ScanCubit>().clearResult(),
      ),
    );
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.file(
            File(imagePath),
            cacheWidth: 1080,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          left: 22.w,
          top: 202.h,
          width: 346.w,
          height: 463.h,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.cf9f9f9, width: 1),
            ),
          ),
        ),
        if (isLoading)
          Positioned(
            left: 22.w,
            right: 22.w,
            top: 202.h - 36.h,
            child: _ScanAnalyzingTextStatic(
              steps: [
                l10n.scanStep1,
                l10n.scanStep2,
                l10n.scanStep3,
                l10n.scanStep4,
                l10n.scanStep5,
              ],
            ),
          ),
        if (result != null && !showTranslation)
          Positioned(
            left: 12.w,
            right: 12.w,
            bottom: 12.h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.only(
                    top: 23.h,
                    right: 16.w,
                    bottom: 23.h,
                    left: 16.w,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x03000000), Color(0x03000000)],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        result.result.artifact.name ??
                            l10n.detailsUnknownArtifact,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (result.result.artifact.description != null)
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            result.result.artifact.description ?? '',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (result.result.artifact.isPrimaryModel) ...[
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            if (result.result.artifact.artifactModelId != null)
                              GestureDetector(
                                onTap: () {
                                  final artifact = result.result.artifact;
                                  Navigator.push(
                                    context,
                                    SmoothRoute(
                                      type: TransitionType.fadeSlideUp,
                                      page: ChatView(
                                        artifactId:
                                            artifact.artifactModelId ?? '',
                                        artifactName:
                                            artifact.name ??
                                            artifact.artifactModelId ??
                                            '',
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 45.r,
                                  height: 45.r,
                                  padding: EdgeInsets.all(14.r),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0x13FFFFFF),
                                        Color(0x00FFFFFF),
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.chat_outlined,
                                    color: Colors.white,
                                    size: 20.r,
                                  ),
                                ),
                              ),
                            if (result.result.artifact.artifactModelId != null)
                              const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  SmoothRoute(
                                    type: TransitionType.fadeSlideUp,
                                    page: BlocProvider.value(
                                      value: context.read<ScanCubit>(),
                                      child: DetailsView(
                                        args: ScanResultArgs(
                                          result: result.result,
                                          imagePath: result.imagePath,
                                          isFavorited: result.isFavorited,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50.r),
                                  border: Border.all(
                                    color: Colors.black.withValues(alpha: 0.1),
                                  ),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0x13FFFFFF),
                                      Color(0x00FFFFFF),
                                    ],
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      l10n.scanDetails,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Gap(4.w),
                                    Icon(
                                      Directionality.of(context) ==
                                              TextDirection.rtl
                                          ? Icons.arrow_back_rounded
                                          : Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 18.r,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        // Translation toggle button
        if (result != null &&
            onToggleTranslation != null &&
            result.result.hieroglyphs?.translation != null)
          PositionedDirectional(
            end: 17.w,
            top: 163.h,
            width: 123.w,
            height: 34.h,
            child: GestureDetector(
              onTap: onToggleTranslation,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF568D3F), Color(0xFF568D3F)],
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            showTranslation
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: Colors.white,
                            size: 14.r,
                          ),
                          Gap(2.w),
                          Text(
                            showTranslation
                                ? l10n.scanHideTranslation
                                : l10n.scanRevealTranslation,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        // Translation card overlay
        if (result != null &&
            showTranslation &&
            result.result.hieroglyphs?.translation != null)
          Positioned(
            left: 8.w,
            top: 261.h,
            width: 375.w,
            bottom: 12.h,
            child: SingleChildScrollView(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 375.w,
                    padding: EdgeInsets.only(
                      top: 27.h,
                      right: 34.w,
                      bottom: 27.h,
                      left: 34.w,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x03000000), Color(0x03000000)],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          l10n.detailsTranslationReveals,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Gap(12.h),
                        Text(
                          result.result.hieroglyphs!.translation!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        backButton,
        if (!isLoading && result == null)
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 40,
            child: Center(
              child: TextButton.icon(
                onPressed: () => context.read<ScanCubit>().clearResult(),
                icon: Icon(
                  Icons.refresh,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 18.r,
                ),
                label: Text(
                  l10n.scanDifferentPhoto,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoading(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppLoading.page(message: l10n.scanAnalyzing);
  }

  Widget _buildResult(BuildContext context, ScanResultLoaded state) {
    final l10n = AppLocalizations.of(context)!;
    final result = state.result;
    final artifact = result.artifact;
    final hieroglyphs = result.hieroglyphs;
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.imagePath != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.file(
                    File(state.imagePath!),
                    cacheWidth: 400,
                    height: 350.h,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                if (result.scanLogId != null)
                  Positioned(
                    top: 12.h,
                    right: 12.w,
                    child: GestureDetector(
                      onTap: () => _saveToFavorites(context, result.scanLogId!),
                      child: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: AppColors.of(
                            context,
                          ).surface.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          state.isFavorited
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: state.isFavorited
                              ? Colors.redAccent
                              : Colors.white,
                          size: 24.r,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          Gap(20.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  artifact.name ?? l10n.detailsUnknownArtifact,
                  style: TextStyle(
                    color: AppColors.of(context).footer,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (result.scanLogId != null) ...[
                Gap(12.w),
                GestureDetector(
                  onTap: () => _saveToFavorites(context, result.scanLogId!),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: state.isFavorited
                          ? Colors.redAccent.withValues(alpha: 0.15)
                          : AppColors.of(
                              context,
                            ).surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: state.isFavorited
                            ? Colors.redAccent.withValues(alpha: 0.4)
                            : AppColors.of(
                                context,
                              ).footer.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          state.isFavorited
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: state.isFavorited
                              ? Colors.redAccent
                              : AppColors.of(
                                  context,
                                ).footer.withValues(alpha: 0.5),
                          size: 16.r,
                        ),
                        Gap(6.w),
                        Text(
                          state.isFavorited
                              ? l10n.scanFavorited
                              : l10n.scanSave,
                          style: TextStyle(
                            color: state.isFavorited
                                ? Colors.redAccent
                                : AppColors.of(
                                    context,
                                  ).footer.withValues(alpha: 0.6),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          if (artifact.isPrimaryModel &&
              (artifact.era != null || artifact.material != null)) ...[
            Gap(12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                if (artifact.era != null)
                  _InfoChip(label: artifact.era!, icon: Icons.history),
                if (artifact.material != null)
                  _InfoChip(
                    label: artifact.material!,
                    icon: Icons.square_outlined,
                  ),
                if (artifact.category != null)
                  _InfoChip(
                    label: artifact.category!,
                    icon: Icons.category_outlined,
                  ),
                if (artifact.type != null)
                  _InfoChip(label: artifact.type!, icon: Icons.image_outlined),
              ],
            ),
          ],

          if (artifact.description != null) ...[
            Gap(16.h),
            Text(
              artifact.description!,
              style: TextStyle(
                color: AppColors.of(context).footer.withValues(alpha: 0.8),
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
          ],

          if (hieroglyphs != null &&
              hieroglyphs.detected &&
              hieroglyphs.translation != null) ...[
            Gap(24.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.of(context).surface.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: AppColors.secondary,
                        size: 18.r,
                      ),
                      Gap(8.w),
                      Text(
                        l10n.scanHieroglyphsTranslation,
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Gap(12.h),
                  Text(
                    hieroglyphs.translation!,
                    style: TextStyle(
                      color: AppColors.of(context).footer,
                      fontSize: 14.sp,
                      height: 1.6,
                    ),
                  ),
                  if (hieroglyphs.totalLines != null ||
                      hieroglyphs.totalGlyphs != null) ...[
                    Gap(12.h),
                    Divider(
                      color: AppColors.of(
                        context,
                      ).footer.withValues(alpha: 0.1),
                    ),
                    Gap(8.h),
                    Row(
                      children: [
                        if (hieroglyphs.totalLines != null)
                          _StatChip(
                            l10n.scanStatLines(hieroglyphs.totalLines!),
                            Icons.horizontal_rule,
                          ),
                        if (hieroglyphs.totalGlyphs != null)
                          _StatChip(
                            l10n.scanStatGlyphs(hieroglyphs.totalGlyphs!),
                            Icons.text_fields,
                          ),
                        if (hieroglyphs.cartoucheCount != null)
                          _StatChip(
                            l10n.scanStatCartouches(
                              hieroglyphs.cartoucheCount!,
                            ),
                            Icons.circle_outlined,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (hieroglyphs != null && !hieroglyphs.detected) ...[
            Gap(16.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.of(context).surface.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.of(context).footer.withValues(alpha: 0.5),
                    size: 18.r,
                  ),
                  Gap(8.w),
                  Text(
                    l10n.scanNoHieroglyphs,
                    style: TextStyle(
                      color: AppColors.of(
                        context,
                      ).footer.withValues(alpha: 0.5),
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],

          Gap(28.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: [
              if (hieroglyphs != null &&
                  (hieroglyphs.translation?.isNotEmpty == true))
                _ActionButton(
                  icon: Icons.auto_awesome,
                  label: l10n.scanHieroglyphs,
                  color: AppColors.secondary,
                  onTap: () => _showHieroglyphsSheet(
                    context,
                    hieroglyphs.translation ?? '',
                  ),
                ),
              _ActionButton(
                icon: Icons.refresh,
                label: l10n.scanNewScan,
                color: AppColors.of(context).footer.withValues(alpha: 0.6),
                onTap: () => context.read<ScanCubit>().clearResult(),
              ),
              if (artifact.artifactModelId != null && artifact.isPrimaryModel)
                _ActionButton(
                  icon: Icons.chat_outlined,
                  label: l10n.scanChat,
                  color: AppColors.secondary,
                  onTap: () {
                    Navigator.push(
                      context,
                      SmoothRoute(
                        type: TransitionType.fadeSlideUp,
                        page: ChatView(
                          artifactId: artifact.artifactModelId,
                          artifactName:
                              artifact.name ?? artifact.artifactModelId,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          Gap(40.h),
        ],
      ),
    );
  }

  void _showHieroglyphsSheet(BuildContext context, String translation) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: 0.7.sh,
        decoration: BoxDecoration(
          color: AppColors.of(ctx).surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.of(ctx).footer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppColors.secondary,
                    size: 22.r,
                  ),
                  Gap(10.w),
                  Text(
                    l10n.scanHieroglyphsTranslation,
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.of(ctx).footer.withValues(alpha: 0.1)),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.r),
                child: SelectableText(
                  translation,
                  style: TextStyle(
                    color: AppColors.of(ctx).footer,
                    fontSize: 16.sp,
                    height: 1.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRejected(BuildContext context, ScanFilterRejected state) {
    final l10n = AppLocalizations.of(context)!;
    final isBlurry = state.sharpness != null;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenUtils.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isBlurry ? Icons.blur_on : Icons.image_not_supported_outlined,
              size: ScreenUtils.iconXl,
              color: Colors.orange.withValues(alpha: 0.6),
            ),
            Gap(ScreenUtils.md),
            Text(
              state.reason,
              style: TextStyle(color: Colors.orange, fontSize: 15.sp),
              textAlign: TextAlign.center,
            ),
            Gap(ScreenUtils.lg),
            _ScanButton(
              icon: Icons.refresh,
              label: l10n.scanTryAgain,
              onTap: () => context.read<ScanCubit>().clearResult(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoArtifactDetected(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenUtils.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_search,
              size: ScreenUtils.iconXl * 1.5,
              color: Colors.orangeAccent.withValues(alpha: 0.6),
            ),
            Gap(ScreenUtils.md),
            Text(
              l10n.scanTryAgain,
              style: TextStyle(
                color: Colors.orangeAccent,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Gap(ScreenUtils.sm),
            Text(
              l10n.scanAdjustImage,
              style: TextStyle(
                color: Colors.orangeAccent.withValues(alpha: 0.7),
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(ScreenUtils.lg),
            _ScanButton(
              icon: Icons.refresh,
              label: l10n.scanTryAgain,
              onTap: () => context.read<ScanCubit>().clearResult(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, ScanError state) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenUtils.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: ScreenUtils.iconXl,
              color: Colors.redAccent.withValues(alpha: 0.6),
            ),
            Gap(ScreenUtils.md),
            Text(
              state.message,
              style: TextStyle(color: Colors.redAccent, fontSize: 15.sp),
              textAlign: TextAlign.center,
            ),
            Gap(ScreenUtils.lg),
            _ScanButton(
              icon: Icons.refresh,
              label: l10n.scanTryAgain,
              onTap: () => context.read<ScanCubit>().clearResult(),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassSelectionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _GlassSelectionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomGlassContainer(
        borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
        padding: EdgeInsets.all(ScreenUtils.md),
        color: AppColors.of(context).footer.withValues(alpha: 0.03),
        borderColor: AppColors.of(context).footer.withValues(alpha: 0.08),
        gradient: LinearGradient(
          colors: [
            AppColors.of(context).footer.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        width: double.infinity,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(ScreenUtils.sm),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(ScreenUtils.radiusSm),
              ),
              child: Icon(
                icon,
                color: AppColors.secondary,
                size: ScreenUtils.iconLg,
              ),
            ),
            Gap(ScreenUtils.md),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.of(context).footer,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.of(context).footer.withValues(alpha: 0.3),
              size: ScreenUtils.iconMd,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ScanButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20.r),
        label: Text(
          label,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
          foregroundColor: AppColors.secondary,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18.r, color: color),
                Gap(8.w),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.of(context).footer.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.r, color: AppColors.secondary),
          Gap(6.w),
          Text(
            label,
            style: TextStyle(
              color: AppColors.of(context).footer.withValues(alpha: 0.7),
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _StatChip(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: 16.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13.r,
            color: AppColors.of(context).footer.withValues(alpha: 0.5),
          ),
          Gap(4.w),
          Text(
            label,
            style: TextStyle(
              color: AppColors.of(context).footer.withValues(alpha: 0.6),
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanAnalyzingTextStatic extends StatefulWidget {
  final List<String> steps;
  const _ScanAnalyzingTextStatic({required this.steps});

  @override
  State<_ScanAnalyzingTextStatic> createState() =>
      _ScanAnalyzingTextStaticState();
}

class _ScanAnalyzingTextStaticState extends State<_ScanAnalyzingTextStatic>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _stepIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _startStepTimer();
  }

  void _startStepTimer() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 1600));
      if (!mounted) break;
      setState(() {
        _stepIndex = (_stepIndex + 1) % widget.steps.length;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.45,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: Text(
          widget.steps[_stepIndex],
          key: ValueKey(_stepIndex),
          style: TextStyle(
            color: Colors.white,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
