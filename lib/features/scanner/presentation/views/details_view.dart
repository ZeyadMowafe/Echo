import 'dart:io';

import 'dart:ui';

import 'package:echo_explorer/core/constants/app_colors.dart';

import 'package:echo_explorer/core/constants/app_strings.dart';

import 'package:echo_explorer/core/widgets/custom_bottom_nav_bar.dart';

import 'package:echo_explorer/core/widgets/custom_floating_action_button.dart';

import 'package:echo_explorer/core/widgets/custom_glass_drawer.dart';

import 'package:echo_explorer/features/chat/presentation/views/chat_view.dart';

import 'package:echo_explorer/core/widgets/custom_glass_app_bar.dart';

import 'package:echo_explorer/features/home/presentation/cubit/features_cubit.dart';

import 'package:echo_explorer/features/scanner/data/models/scan_result_args.dart';

import 'package:echo_explorer/features/scanner/domain/entities/scan_response_entity.dart';

import 'package:echo_explorer/features/scanner/presentation/cubit/scan_cubit.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:gap/gap.dart';

class DetailsView extends StatefulWidget {
  final ScanResultArgs args;
  const DetailsView({
super.key, required this.args}
);
  @override  State<DetailsView> createState() => _DetailsViewState();
}
class _DetailsViewState extends State<DetailsView> {
  bool _showTranslation = false;
  bool _showToast = false;
  bool _toastIsFavorited = false;
  ScanResponseEntity get _result => widget.args.result;
  String? get _imagePath => widget.args.imagePath;
  void _showFavoriteToast() {
    _toastIsFavorited =        context.read<ScanCubit>().state is ScanResultLoaded &&        (context.read<ScanCubit>().state as ScanResultLoaded).isFavorited;
    setState(() => _showToast = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showToast = false);
    }
);
  }
  void _toggleFavorite() {
    final scanLogId = _result.scanLogId;
    if (scanLogId == null) return;
    context.read<ScanCubit>().toggleScanResultFavorite(scanLogId);
    _showFavoriteToast();
  }
  @override  void dispose() {
    super.dispose();
  }
  @override  Widget build(BuildContext context) {
    final scanState = context.watch<ScanCubit>().state;
    final isFavorited = scanState is ScanResultLoaded && scanState.isFavorited;
    final hasScanLogId = _result.scanLogId != null;
    return Scaffold(      backgroundColor: const Color(0xFF0D1215),      drawer: CustomGlassDrawer(        currentFeature: AppStrings.scanFeature.key,        onTap: (featureName) {
          final cubit = context.read<FeaturesCubit>();
          Navigator.of(context).popUntil((route) => route.isFirst);
          cubit.changeFeature(featureName: featureName);
        }
,      ),      floatingActionButton: CustomFloatingActionButton(        onPressed: () {
          final cubit = context.read<FeaturesCubit>();
          Navigator.of(context).popUntil((route) => route.isFirst);
          cubit.changeFeature(featureName: AppStrings.scanFeature.key);
        }
,      ),      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,      bottomNavigationBar: CustomBottomNavBar(        currentFeature: AppStrings.scanFeature.key,        onTap: (featureName) {
          final cubit = context.read<FeaturesCubit>();
          Navigator.of(context).popUntil((route) => route.isFirst);
          cubit.changeFeature(featureName: featureName);
        }
,      ),      body: Column(        children: [          CustomDiscoverAppBar(            previousState: AppStrings.scanFeature.key,            title: 'Details',            onPressed: () => Navigator.pop(context),            trailingBuilder: (ctx) => GestureDetector(              onTap: () => Scaffold.of(ctx).openDrawer(),              child: Icon(                Icons.menu_rounded,                size: 28.r,                color: AppColors.of(context).footer.withValues(alpha: 0.7),              ),            ),          ),          Expanded(            child: Stack(              children: [                SingleChildScrollView(                  padding: EdgeInsets.symmetric(horizontal: 19.w),                  child: Column(                    crossAxisAlignment: CrossAxisAlignment.start,                    children: [                      Gap(32.h),                      // Action bar: Reveal Translation + Heart + Share                      if (_result.hieroglyphs?.detected == true &&                          _result.hieroglyphs?.translation != null)                        SizedBox(                          width: double.infinity,                          height: 32.h,                          child: Row(                            children: [                              GestureDetector(                                onTap: () => setState(                                  () => _showTranslation = !_showTranslation,                                ),                                child: ClipRRect(                                  borderRadius: BorderRadius.circular(24.r),                                  child: BackdropFilter(                                    filter: ImageFilter.blur(                                      sigmaX: 15,                                      sigmaY: 15,                                    ),                                    child: Container(                                      padding: EdgeInsets.symmetric(                                        horizontal: 10.w,                                        vertical: 6.h,                                      ),                                      decoration: BoxDecoration(                                        borderRadius: BorderRadius.circular(24.r),                                        border: Border.all(                                          color: Colors.white.withValues(                                            alpha: 0.1,                                          ),                                        ),                                        gradient: const LinearGradient(                                          begin: Alignment.topCenter,                                          end: Alignment.bottomCenter,                                          colors: [                                            Color(0x05FFFFFF),                                            Colors.transparent,                                          ],                                        ),                                      ),                                      child: Row(                                        mainAxisSize: MainAxisSize.min,                                        children: [                                          Icon(                                            _showTranslation                                                ? Icons.format_list_bulleted                                                : Icons.visibility_rounded,                                            color: Colors.white,                                            size: 12.r,                                          ),                                            Gap(4.w),                                            Text(                                              _showTranslation                                                  ? 'About This Artifact'                                                  : 'Reveal Translation',                                              style: TextStyle(                                                color: Colors.white,                                                fontSize: 11.sp,                                                fontWeight: FontWeight.w400,                                              ),                                          ),                                        ],                                      ),                                    ),                                  ),                                ),                              ),                              const Spacer(),                              GestureDetector(                                onTap: _toggleFavorite,                                child: Icon(                                  hasScanLogId && isFavorited                                      ? Icons.favorite                                      : Icons.favorite_border_rounded,                                  size: 24.r,                                  color: hasScanLogId && isFavorited                                      ? Colors.redAccent                                      : AppColors.of(                                          context,                                        ).footer.withValues(alpha: 0.6),                                ),                              ),                              Gap(10.w),                              GestureDetector(                                onTap: () {
                                  /* share */                                }
,                                child: Icon(                                  Icons.share_outlined,                                  size: 24.r,                                  color: AppColors.of(                                    context,                                  ).footer.withValues(alpha: 0.6),                                ),                              ),                            ],                          ),                        ),                      Gap(32.h),                      // Product image                      if (_imagePath != null)                        Center(                          child: ClipRRect(                            borderRadius: BorderRadius.circular(24.r),                            child: Image.file(                              File(_imagePath!),                              width: 150.w,                              height: 220.h,                              fit: BoxFit.contain,                            ),                          ),                        ),                      // Translation text (when toggled)                      if (_showTranslation &&                          _result.hieroglyphs?.translation != null) ...[                        Gap(32.h),                        Text(                          'Discover what the translation reveals…',                          style: TextStyle(                            color: Colors.white,                            fontSize: 20.sp,                            height: 1.2,                            fontWeight: FontWeight.w400,                          ),                        ),                        Gap(12.h),                        Text(                          _result.hieroglyphs!.translation!,                          style: TextStyle(                            color: Colors.white.withValues(alpha: 0.85),                            fontSize: 14.sp,                            fontWeight: FontWeight.w400,                            height: 1.4,                          ),                        ),                      ],                      if (!_showTranslation) ...[                        Gap(32.h),                        // Artifact name                        Text(                          _result.artifact.name ?? 'Artifact',                          style: TextStyle(                            color: Colors.white,                            fontSize: 22.sp,                            fontWeight: FontWeight.w700,                          ),                        ),                        // Artifact info as comma-separated text                        () {
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
                          return Padding(                            padding: EdgeInsets.only(top: 8.h),                            child: Text(                              parts.join('  |  '),                              style: TextStyle(                                color: Colors.white,                                fontSize: 14.sp,                                fontWeight: FontWeight.w400,                              ),                            ),                          );
                        }
(),                      ],                      if (!_showTranslation) ...[                        Gap(32.h),                        // Divider                        Container(                          width: 337.w,                          height: 0,                          decoration: BoxDecoration(                            border: Border(                              top: BorderSide(                                color: AppColors.of(                                  context,                                ).footer.withValues(alpha: 0.15),                                width: 1,                              ),                            ),                          ),                        ),                        Gap(32.h),                        Text(                          'Description',                          style: TextStyle(                            color: Colors.white,                            fontSize: 22.sp,                            fontWeight: FontWeight.w900,                          ),                        ),                        Gap(12.h),                        // Description                        Text(                          _result.artifact.description ?? '',                          style: TextStyle(                            color: Colors.white,                            fontSize: 16.sp,                            height: 1.2,                            fontWeight: FontWeight.w400,                          ),                        ),                      ],                      Gap(32.h),                      // Chat with me button (glass style)                      Center(                        child: GestureDetector(                          onTap: () {
                            Navigator.push(                              context,                              MaterialPageRoute(                                builder: (_) => ChatView(                                  artifactId:                                      _result.artifact.artifactModelId ?? '',                                  artifactName:                                      _result.artifact.name ??                                      _result.artifact.artifactModelId ??                                      '',                                ),                              ),                            );
                          }
,                          child: ClipRRect(                            borderRadius: BorderRadius.circular(24.r),                            child: BackdropFilter(                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),                              child: Container(                                width: 335.w,                                height: 43.h,                                decoration: BoxDecoration(                                  borderRadius: BorderRadius.circular(24.r),                                  border: Border.all(                                    color: Colors.white.withValues(alpha: 0.15),                                  ),                                  gradient: const LinearGradient(                                    begin: Alignment.topCenter,                                    end: Alignment.bottomCenter,                                    colors: [                                      Color(0x03000000),                                      Color(0x03000000),                                    ],                                  ),                                ),                                child: Center(                                  child: Text(                                    'chat with me',                                    style: TextStyle(                                      fontSize: 17.sp,                                      fontWeight: FontWeight.w600,                                      color: Colors.white,                                    ),                                  ),                                ),                              ),                            ),                          ),                        ),                      ),                      Gap(40.h),                    ],                  ),                ),                if (_showToast)                  Positioned(                    top: 35.h,                    left: 0,                    right: 0,                    child: Center(                      child: Container(                        width: 300.w,                        padding: EdgeInsets.symmetric(                          vertical: 10.h,                          horizontal: 16.w,                        ),                        decoration: BoxDecoration(                          color: const Color(                            0xFF0D1215,                          ).withValues(alpha: 0.92),                          borderRadius: BorderRadius.circular(24.r),                        ),                        child: Center(                          child: Row(                            mainAxisSize: MainAxisSize.min,                            children: [                              Icon(                                _toastIsFavorited                                    ? Icons.favorite                                    : Icons.favorite_border,                                size: 18.r,                                color: Colors.white,                              ),                              Gap(10.w),                              Text(                                _toastIsFavorited                                    ? 'Added to Your Favorites'                                    : 'Removed from Favorites',                                style: TextStyle(                                  fontFamily: 'Inter',                                  fontWeight: FontWeight.w500,                                  fontSize: 15.sp,                                  color: Colors.white,                                ),                              ),                            ],                          ),                        ),                      ),                    ),                  ),              ],            ),          ),        ],      ),    );
  }
}
