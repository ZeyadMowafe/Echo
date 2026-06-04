import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/routing/app_transitions.dart';
import 'package:echo_explorer/core/widgets/app_loading.dart';
import 'package:echo_explorer/core/widgets/custom_glass_back_button.dart';
import 'package:echo_explorer/core/widgets/custom_glass_drawer.dart';
import 'package:echo_explorer/features/home/presentation/cubit/features_cubit.dart';
import 'package:echo_explorer/features/scanner/data/models/scan_result_args.dart';
import 'package:echo_explorer/features/scanner/domain/entities/scan_response_entity.dart';
import 'package:echo_explorer/features/scanner/presentation/cubit/scan_cubit.dart';
import 'package:echo_explorer/features/scanner/presentation/views/details_view.dart';
import 'package:echo_explorer/features/chat/presentation/views/chat_view.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

enum _ScanPhase { scanning, analyzing, result, error }

class CameraScannerView extends StatefulWidget {
  final String? initialImagePath;
  const CameraScannerView({super.key, this.initialImagePath});

  @override
  State<CameraScannerView> createState() => _CameraScannerViewState();
}

class _CameraScannerViewState extends State<CameraScannerView> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isScanning = false;
  bool _isDone = false;
  _ScanPhase _phase = _ScanPhase.scanning;
  String? _capturedImagePath;
  bool _showTranslation = false;
  bool _showFullTranslation = false;
  bool _isStable = false;
  late final ScanCubit _cubit;
  final ImagePicker _picker = ImagePicker();
  Timer? _panAwayTimer;
  StreamSubscription<bool>? _stabilitySub;
  StreamSubscription<bool>? _cooldownSub;

  @override
  void initState() {
    _cubit = context.read<ScanCubit>();
    super.initState();
    if (widget.initialImagePath != null) {
      setState(() => _isInitialized = true);
    } else {
      _initCamera();
    }
    // Use the unified pipeline from ScanCubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<ScanCubit>();
      cubit.pipeline.startMotionDetection();
      _stabilitySub = cubit.pipeline.stabilityStream.listen((stable) {
        if (!mounted) return;
        setState(() => _isStable = stable);
        // Gate 4 reset: only reset if user keeps moving for ~1.5s
        if (_phase == _ScanPhase.result && cubit.state is ScanAnchored) {
          if (!stable) {
            _panAwayTimer ??= Timer(const Duration(seconds: 3), () {
              if (!mounted) return;
              final cubit = context.read<ScanCubit>();
              if (cubit.state is! ScanAnchored) return;
              cubit.onPanAway();
              setState(() {
                _phase = _ScanPhase.scanning;
                _isScanning = false;
                _capturedImagePath = null;
                _showTranslation = false;
                _showFullTranslation = false;
                _controller = null;
                _isInitialized = false;
              });
              _initCamera();
            });
          } else {
            _panAwayTimer?.cancel();
            _panAwayTimer = null;
          }
        }
      });
    });
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  Future<void> _onCapturePressed() async {
    if (_isScanning || _isDone) return;
    setState(() => _isScanning = true);
    String? path;
    if (widget.initialImagePath != null) {
      path = widget.initialImagePath;
    } else if (_controller != null && _isInitialized) {
      final file = await _controller!.takePicture();
      _controller?.dispose();
      _controller = null;
      path = file.path;
    }
    if (path == null || !mounted) return;
    _capturedImagePath = path;
    setState(() => _phase = _ScanPhase.analyzing);
    final cubit = context.read<ScanCubit>();
    cubit.setImagePath(path);
    cubit.analyzeImage(skipBlurCheck: true);
  }

  Future<void> _pickFromGallery() async {
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null || !mounted) return;
      _capturedImagePath = file.path;
      setState(() => _phase = _ScanPhase.analyzing);
      final cubit = context.read<ScanCubit>();
      cubit.setImagePath(file.path);
      cubit.analyzeImage(skipBlurCheck: true);
    } on PlatformException catch (_) {}
  }

  @override
  void dispose() {
    _panAwayTimer?.cancel();
    _stabilitySub?.cancel();
    _cooldownSub?.cancel();
    _cubit.pipeline.stopMotionDetection();
    if (!_isDone) {
      _controller?.dispose();
      _controller = null;
    }
    super.dispose();
  }

  /// Extract result data from either ScanResultLoaded or ScanAnchored
  ({bool present, ScanResponseEntity? result, String? imagePath, bool isFav})
  _resultFrom(ScanState s) {
    if (s is ScanResultLoaded)
      return (
        present: true,
        result: s.result,
        imagePath: s.imagePath,
        isFav: s.isFavorited,
      );
    if (s is ScanAnchored)
      return (
        present: true,
        result: s.result,
        imagePath: s.imagePath,
        isFav: s.isFavorited,
      );
    return (present: false, result: null, imagePath: null, isFav: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scanState = context.watch<ScanCubit>().state;
    final resultData = _resultFrom(scanState);
    if (_phase == _ScanPhase.analyzing) {
      if (scanState is ScanResultLoaded || scanState is ScanAnchored) {
        _phase = _ScanPhase.result;
      } else if (scanState is ScanError) {
        _phase = _ScanPhase.error;
      }
    }
    return BlocListener<ScanCubit, ScanState>(
      listener: (context, state) {
        if (state is ScanFilterRejected || state is ScanError) {
          // Show message to adjust image
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orangeAccent,
                    size: 20.r,
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Text(
                      l10n.scanAdjustImage,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.of(context).surface,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              duration: const Duration(seconds: 3),
            ),
          );

          // Reset the scanner view state and clear cubit result
          context.read<ScanCubit>().clearResult();
          setState(() {
            _phase = _ScanPhase.scanning;
            _isScanning = false;
            _capturedImagePath = null;
            _showTranslation = false;
            _showFullTranslation = false;
            _controller = null;
            _isInitialized = false;
          });
          _initCamera();
        }
      },
      child: Scaffold(
      backgroundColor: Colors.black,
      drawerScrimColor: Colors.transparent,
      drawer: CustomGlassDrawer(
        currentFeature: AppStrings.scanFeature.key,
        onTap: (featureName) {
          final cubit = context.read<FeaturesCubit>();
          Navigator.of(context).popUntil((route) => route.isFirst);
          cubit.changeFeature(featureName: featureName);
        },
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Full-screen image/camera preview
            if (_isInitialized && _capturedImagePath != null)
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.file(
                  File(_capturedImagePath!),
                  cacheWidth: 1080,
                  fit: BoxFit.cover,
                ),
              )
            else if (_isInitialized &&
                widget.initialImagePath != null &&
                _capturedImagePath == null)
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.file(
                  File(widget.initialImagePath!),
                  cacheWidth: 1080,
                  fit: BoxFit.cover,
                ),
              )
            else if (_isInitialized && _controller != null)
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: CameraPreview(_controller!),
              )
            else
              AppLoading.page(),
            // Viewfinder overlay
            Positioned(
              left: 22.w,
              top: 170.h,
              width: 346.w,
              height: 463.h,
              child: (_phase == _ScanPhase.analyzing)
                  ? FuturisticScanAnalyzerOverlay(
                      steps: [
                        l10n.scanStep1,
                        l10n.scanStep2,
                        l10n.scanStep3,
                        l10n.scanStep4,
                        l10n.scanStep5,
                      ],
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColors.cf9f9f9, width: 1),
                      ),
                    ),
            ),
            // Scanning indicator
            if (_phase == _ScanPhase.scanning && _isScanning)
              Positioned(
                left: 0,
                right: 0,
                top: 170.h + 463.h + 20.h,
                child: Center(child: AppLoading.scanner()),
              ),
            // Capture button (Gate 1: only visible when stable + not scanning)
            if (_phase == _ScanPhase.scanning && !_isScanning)
              Positioned(
                left: 0,
                right: 0,
                bottom: MediaQuery.of(context).padding.bottom + 20.h,
                child: Center(
                  child: GestureDetector(
                    onTap: _isStable ? _onCapturePressed : null,
                    child: Container(
                      width: 72.r,
                      height: 72.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isStable
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.3),
                        border: Border.all(
                          color: _isStable
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.3),
                          width: 4,
                        ),
                        boxShadow: _isStable
                            ? [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Container(
                          width: 60.r,
                          height: 60.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isStable
                                ? Colors.white
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // Gallery picker button (bottom left, during scanning)
            if (_phase == _ScanPhase.scanning && !_isScanning)
              Positioned(
                left: 24.w,
                bottom: MediaQuery.of(context).padding.bottom + 20.h,
                child: GestureDetector(
                  onTap: _pickFromGallery,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 44.r,
                        height: 44.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.photo_library_outlined,
                          color: Colors.white,
                          size: 22.r,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // Result overlay card (hidden when translation is shown)
            if (_phase == _ScanPhase.result &&
                resultData.present &&
                !_showTranslation)
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
                            resultData.result?.artifact.name ??
                                l10n.detailsUnknownArtifact,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w900,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (resultData.result?.artifact.name != null)
                            Builder(
                              builder: (context) {
                                final parts = <String>[];
                                final a = resultData.result!.artifact;
                                if (a.era != null) parts.add(a.era!);
                                if (a.material != null) parts.add(a.material!);
                                if (a.category != null) parts.add(a.category!);
                                if (a.type != null) parts.add(a.type!);
                                if (parts.isEmpty)
                                  return const SizedBox.shrink();
                                return Padding(
                                  padding: EdgeInsets.only(top: 8.h),
                                  child: Center(
                                    child: Text(
                                      parts.join('  |  '),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          if (resultData.result?.artifact.name == null &&
                              resultData.result?.artifact.description != null)
                            Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text(
                                resultData.result!.artifact.description!,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (resultData.result!.artifact.isPrimaryModel) ...[
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                if (resultData
                                        .result!
                                        .artifact
                                        .artifactModelId !=
                                    null)
                                  GestureDetector(
                                    onTap: () {
                                      final artifact =
                                          resultData.result!.artifact;
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
                                if (resultData
                                        .result!
                                        .artifact
                                        .artifactModelId !=
                                    null)
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
                                              result: resultData.result!,
                                              imagePath: resultData.imagePath,
                                              isFavorited: resultData.isFav,
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
            // Hieroglyphs translation toggle button
            if (_phase == _ScanPhase.result &&
                resultData.present &&
                resultData.result?.hieroglyphs?.translation != null)
              PositionedDirectional(
                end: 17.w,
                top: 163.h,
                width: 123.w,
                height: 34.h,
                child: GestureDetector(
                  onTap: () => setState(() {
                    _showTranslation = !_showTranslation;
                    if (!_showTranslation) _showFullTranslation = false;
                  }),
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
                                _showTranslation
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: Colors.white,
                                size: 14.r,
                              ),
                              Gap(2.w),
                              Text(
                                _showTranslation
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
            // Translation card overlay (top position)
            if (_phase == _ScanPhase.result &&
                resultData.present &&
                resultData.result?.hieroglyphs?.translation != null &&
                _showTranslation &&
                !_showFullTranslation)
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
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _showTranslation = false),
                                  child: Icon(
                                    Directionality.of(context) ==
                                            TextDirection.rtl
                                        ? Icons.arrow_forward_rounded
                                        : Icons.arrow_back_rounded,
                                    color: Colors.white70,
                                    size: 22.r,
                                  ),
                                ),
                              ],
                            ),
                            Gap(12.h),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _showFullTranslation = true),
                              child: Text(
                                textAlign: TextAlign.center,
                                resultData.result!.hieroglyphs!.translation!,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // Full translation detail overlay
            if (_showFullTranslation &&
                _phase == _ScanPhase.result &&
                resultData.present &&
                resultData.result?.hieroglyphs?.translation != null)
              Positioned(
                left: 12.w,
                top: 611.h,
                width: 366.w,
                child: AnimatedOpacity(
                  opacity: _showFullTranslation ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => setState(
                                    () => _showFullTranslation = false,
                                  ),
                                  child: Icon(
                                    Directionality.of(context) ==
                                            TextDirection.rtl
                                        ? Icons.arrow_forward_rounded
                                        : Icons.arrow_back_rounded,
                                    color: Colors.white70,
                                    size: 22.r,
                                  ),
                                ),
                                Gap(8.w),
                                Expanded(
                                  child: Text(
                                    'Translation',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Gap(12.h),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  resultData.result!.hieroglyphs!.translation!,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 14.sp,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // Error overlay
            if (_phase == _ScanPhase.error && scanState is ScanError)
              Positioned(
                left: 12.w,
                top: 584.h,
                width: 366.w,
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    color: Colors.black.withValues(alpha: 0.7),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.redAccent.withValues(alpha: 0.8),
                        size: 28.r,
                      ),
                      Gap(8.h),
                      Text(
                        scanState.message,
                        style: TextStyle(color: Colors.white, fontSize: 13.sp),
                        textAlign: TextAlign.center,
                      ),
                      Gap(12.h),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Back',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Top bar (back + menu, no blur)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                child: Row(
                  children: [
                    CustomGlassBackButton(
                      iconColor: Colors.white,
                      onPressed: () {
                        if (_phase == _ScanPhase.result) {
                          context.read<ScanCubit>().clearResult();
                          setState(() {
                            _phase = _ScanPhase.scanning;
                            _isScanning = false;
                            _capturedImagePath = null;
                            _showTranslation = false;
                            _showFullTranslation = false;
                            _controller = null;
                            _isInitialized = false;
                          });
                          _initCamera();
                        } else {
                          _isDone = true;
                          _controller?.dispose();
                          _controller = null;
                          Navigator.pop(context);
                        }
                      },
                    ),
                    const Spacer(),
                    Builder(
                      builder: (ctx) => GestureDetector(
                        onTap: () => Scaffold.of(ctx).openDrawer(),
                        child: Icon(
                          Icons.menu_rounded,
                          size: 28.r,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class _OverlayButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isOutlined;
  final VoidCallback onTap;

  const _OverlayButton({
    required this.label,
    required this.icon,
    required this.isOutlined,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 16.r),
              label: Text(
                label,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 16.r),
              label: Text(
                label,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary.withValues(alpha: 0.3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ),
    );
  }
}
