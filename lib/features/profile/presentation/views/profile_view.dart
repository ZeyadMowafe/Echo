import 'dart:io';
import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/di/injection_container.dart';
import 'package:echo_explorer/core/error/error_handler.dart';
import 'package:echo_explorer/core/error/failures.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/core/hive/cache_helper.dart';
import 'package:echo_explorer/core/routing/app_transitions.dart';
import 'package:echo_explorer/core/widgets/app_loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:echo_explorer/core/widgets/custom_glass_drawer.dart';
import 'package:echo_explorer/core/widgets/custom_glass_container.dart';
import 'package:echo_explorer/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:echo_explorer/features/auth/presentation/widgets/auth_sheet_helper.dart';
import 'package:echo_explorer/core/routing/routes.dart';
import 'package:echo_explorer/features/home/presentation/cubit/features_cubit.dart';
import 'package:echo_explorer/features/scanner/domain/entities/scan_log_entity.dart';
import 'package:echo_explorer/features/scanner/presentation/cubit/scan_cubit.dart';
import 'package:echo_explorer/features/scanner/data/models/scan_result_args.dart';
import 'package:echo_explorer/features/scanner/domain/entities/scan_artifact_entity.dart';
import 'package:echo_explorer/features/scanner/domain/entities/scan_hieroglyphs_entity.dart';
import 'package:echo_explorer/features/scanner/domain/entities/scan_response_entity.dart';
import 'package:echo_explorer/features/scanner/presentation/views/details_view.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  int _selectedTabIndex = 0;
  late final ScanCubit _scanCubit;
  bool _didShowAuthSheet = false;

  // Local state to populate the stats panel
  int? _favoritesCount;
  int? _scansCount;

  @override
  void initState() {
    super.initState();
    _scanCubit = sl<ScanCubit>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didShowAuthSheet) return;
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) {
      _didShowAuthSheet = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showAuthSheet(context, AppLocalizations.of(context).profileAuthMessage);
      });
    } else {
      _didShowAuthSheet = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _loadInitialData();
      });
    }
  }

  @override
  void dispose() {
    _scanCubit.close();
    super.dispose();
  }

  void _loadInitialData() {
    // Eagerly trigger both loads once to populate the stats panel smoothly
    _scanCubit.loadFavorites();
    _scanCubit.loadScanLogs();
  }

  void _loadTabData() {
    if (_selectedTabIndex == 0) {
      _scanCubit.loadFavorites();
    } else {
      _scanCubit.loadScanLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appColors = AppColors.of(context);

    return BlocProvider.value(
      value: _scanCubit,
      child: BlocListener<ScanCubit, ScanState>(
        listener: (context, state) {
          if (state is ScanFavoritesLoaded) {
            setState(() => _favoritesCount = state.favorites.length);
          } else if (state is ScanLogsLoaded) {
            setState(() => _scansCount = state.scanLogs.length);
          } else if (state is ScanError) {
            ErrorHandler.showError(context, ServerFailure(state.message));
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (previous, current) =>
              (previous is! Authenticated && current is Authenticated) ||
              (previous is Authenticated && current is! Authenticated),
          builder: (context, state) {
            final loggedIn = state is Authenticated;
            final userName = loggedIn ? state.userName : '';
            final userEmail = loggedIn ? state.userEmail : '';

            final String? profileImagePath = CacheHelper.getData(
              key: 'profile_image',
            );
            final String? coverImagePath = CacheHelper.getData(
              key: 'cover_image',
            );

            return Scaffold(
              backgroundColor: appColors.background,
              drawerScrimColor: Colors.transparent,
              drawer: CustomGlassDrawer(
                currentFeature: AppStrings.profileFeature.key,
                onTap: (featureName) {
                  final cubit = context.read<FeaturesCubit>();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  cubit.changeFeature(featureName: featureName);
                },
              ),
              body: Stack(
                children: [
                  // 1. Cinematic Ambient Glowing Orbs Background
                  const _ProfileBackgroundOrbs(),

                  // 2. Main Content Canvas
                  Column(
                    children: [
                      _buildAppBar(context, l10n, appColors),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Gap(16.h),
                                _buildProfileCard(
                                  context: context,
                                  loggedIn: loggedIn,
                                  userName: userName,
                                  userEmail: userEmail,
                                  profileImagePath: profileImagePath,
                                  coverImagePath: coverImagePath,
                                  onEdit: () {
                                    if (!loggedIn) {
                                      showAuthSheet(
                                        context,
                                        l10n.profileAuthMessage,
                                      );
                                      return;
                                    }
                                    Navigator.of(
                                      context,
                                    ).pushNamed(AppRoutes.editProfileView);
                                  },
                                ),
                                if (loggedIn) ...[
                                  Gap(24.h),
                                  _buildTabs(l10n, appColors),
                                  Gap(16.h),
                                  _buildTabContent(),
                                ],
                                Gap(120.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
    BaseThemeColors appColors,
  ) {
    return CustomGlassContainer(
      color: appColors.discoverAppBar.withValues(alpha: 0.25),
      gradient: LinearGradient(
        colors: [
          appColors.discoverAppBar.withValues(alpha: 0.30),
          appColors.discoverAppBar.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderColor: appColors.discoverAppBar.withValues(alpha: 0.05),
      padding: EdgeInsets.only(top: 6.h, bottom: 6.h, left: 20.w, right: 20.w),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Builder(
              builder: (innerContext) {
                return CustomGlassContainer(
                  width: ScreenUtils.glassButtonSize,
                  height: ScreenUtils.glassButtonSize,
                  color: appColors.glassBase.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(ScreenUtils.radiusFull),
                  borderColor: appColors.glassBase.withValues(alpha: 0.15),
                  padding: EdgeInsets.zero,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.menu,
                      color: appColors.footer,
                      size: ScreenUtils.iconMd,
                    ),
                    onPressed: () => Scaffold.of(innerContext).openDrawer(),
                  ),
                );
              },
            ),
            Gap(12.w),
            Text(
              l10n.profileTitle,
              style: TextStyle(
                color: appColors.footer,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            CustomGlassContainer(
              width: ScreenUtils.glassButtonSize,
              height: ScreenUtils.glassButtonSize,
              color: appColors.glassBase.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(ScreenUtils.radiusFull),
              borderColor: appColors.glassBase.withValues(alpha: 0.15),
              padding: EdgeInsets.zero,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.settings_outlined,
                  color: appColors.footer,
                  size: ScreenUtils.iconMd,
                ),
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.settingsView),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required BuildContext context,
    required bool loggedIn,
    required String userName,
    required String userEmail,
    String? profileImagePath,
    String? coverImagePath,
    required VoidCallback onEdit,
  }) {
    final appColors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return CustomGlassContainer(
      color: appColors.bottomNavBar.withValues(alpha: 0.35),
      borderColor: appColors.glassBase.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(ScreenUtils.radiusLg),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          SizedBox(
            height: 120.h,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(ScreenUtils.radiusLg),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: appColors.discoverAppBar.withValues(alpha: 0.2),
                      image: coverImagePath != null
                          ? DecorationImage(
                              image: ResizeImage(
                                FileImage(File(coverImagePath)),
                                width: 800,
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ),
                ),
                // Cover Overlay for soft transition
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(ScreenUtils.radiusLg),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                PositionedDirectional(
                  end: 12.w,
                  top: 12.h,
                  child: CustomGlassContainer(
                    width: 34.r,
                    height: 34.r,
                    color: appColors.glassBase.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(17.r),
                    borderColor: appColors.glassBase.withValues(alpha: 0.15),
                    padding: EdgeInsets.zero,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.edit_outlined,
                        color: AppColors.cffffff,
                        size: 18.r,
                      ),
                      onPressed: onEdit,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -40.h,
                  child: _PulsatingAvatar(
                    isLoggedIn: loggedIn,
                    userName: userName,
                    imagePath: profileImagePath,
                    size: 80.r,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(50.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loggedIn ? userName : l10n.profileGuest,
                                style: TextStyle(
                                  color: appColors.footer,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (loggedIn && userEmail.isNotEmpty) ...[
                                Gap(4.h),
                                Text(
                                  userEmail,
                                  style: TextStyle(
                                    color: appColors.footer.withValues(
                                      alpha: 0.6,
                                    ),
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Beautiful Glass Metrics/Stats Row
                    // if (loggedIn) ...[
                    //   Gap(20.h),
                    //   // Divider(
                    //   //   color: AppColors.cffffff.withValues(alpha: 0.08),
                    //   //   thickness: 1,
                    //   // ),
                    //   // Gap(12.h),
                    //   // Row(
                    //   //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   //   children: [
                    //   //     _buildStatItem(
                    //   //       _scansCount?.toString() ?? "—",
                    //   //       l10n.profileScan,
                    //   //       Icons.document_scanner_outlined,
                    //   //       appColors,
                    //   //     ),
                    //   //     Container(
                    //   //       height: 30.h,
                    //   //       width: 1,
                    //   //       color: AppColors.cffffff.withValues(alpha: 0.08),
                    //   //     ),
                    //   //     _buildStatItem(
                    //   //       _favoritesCount?.toString() ?? "—",
                    //   //       l10n.profileFavorite,
                    //   //       Icons.favorite_border_rounded,
                    //   //       appColors,
                    //   //     ),
                    //   //   ],
                    //   // ),
                    // ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String count,
    String label,
    IconData icon,
    BaseThemeColors appColors,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.secondary, size: 16.r),
            Gap(6.w),
            Text(
              count,
              style: TextStyle(
                color: appColors.footer,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Gap(4.h),
        Text(
          label,
          style: TextStyle(
            color: appColors.footer.withValues(alpha: 0.5),
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(AppLocalizations l10n, BaseThemeColors appColors) {
    return CustomGlassContainer(
      padding: EdgeInsets.all(4.r),
      borderRadius: BorderRadius.circular(ScreenUtils.radiusFull),
      color: appColors.bottomNavBar.withValues(alpha: 0.35),
      borderColor: appColors.glassBase.withValues(alpha: 0.05),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedTabIndex = 0);
                _loadTabData();
              },
              child: CustomGlassContainer(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                borderRadius: BorderRadius.circular(ScreenUtils.radiusFull),
                color: _selectedTabIndex == 0
                    ? appColors.footer.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderColor: _selectedTabIndex == 0
                    ? appColors.glassBase.withValues(alpha: 0.1)
                    : Colors.transparent,
                child: Center(
                  child: Text(
                    l10n.profileFavorite,
                    style: TextStyle(
                      color: _selectedTabIndex == 0
                          ? appColors.footer
                          : appColors.footer.withValues(alpha: 0.6),
                      fontSize: 14.sp,
                      fontWeight: _selectedTabIndex == 0
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedTabIndex = 1);
                _loadTabData();
              },
              child: CustomGlassContainer(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                borderRadius: BorderRadius.circular(ScreenUtils.radiusFull),
                color: _selectedTabIndex == 1
                    ? appColors.footer.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderColor: _selectedTabIndex == 1
                    ? appColors.glassBase.withValues(alpha: 0.1)
                    : Colors.transparent,
                child: Center(
                  child: Text(
                    l10n.profileScan,
                    style: TextStyle(
                      color: _selectedTabIndex == 1
                          ? appColors.footer
                          : appColors.footer.withValues(alpha: 0.6),
                      fontSize: 14.sp,
                      fontWeight: _selectedTabIndex == 1
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return BlocBuilder<ScanCubit, ScanState>(
      builder: (context, state) {
        if (state is ScanLoading) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 60.h),
            child: AppLoading.page(),
          );
        }
        if (state is ScanFavoritesLoaded) {
          if (state.favorites.isEmpty) return _buildEmptyState();
          return _buildLogList(state.favorites);
        }
        if (state is ScanLogsLoaded) {
          if (state.scanLogs.isEmpty) return _buildEmptyState();
          return _buildLogList(state.scanLogs);
        }
        if (state is ScanError) {
          return Padding(
            padding: EdgeInsets.all(ScreenUtils.xl),
            child: Center(
              child: Text(
                state.message,
                style: TextStyle(color: Colors.redAccent, fontSize: 14.sp),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildLogList(List<ScanLogEntity> logs) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 78 / 95,
      ),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final imageUrl = log.imageUrl != null
            ? 'https://echo-api-441520148279.me-central1.run.app${log.imageUrl}'
            : null;
        return GestureDetector(
          onTap: () {
            final scanHieroglyphs = log.hieroglyphsTranslation != null
                ? ScanHieroglyphsEntity(
                    detected: true,
                    translation: log.hieroglyphsTranslation,
                  )
                : null;
            final response = ScanResponseEntity(
              status: 'completed',
              processingTimeMs: 0,
              artifact: ScanArtifactEntity(
                isPrimaryModel: false,
                artifactModelId: log.artifactModelId,
                name: log.artifactName,
                description: log.description,
                era: log.era,
                material: log.material,
                category: log.category,
                type: log.type,
                imageUrl: log.imageUrl != null
                    ? 'https://echo-api-441520148279.me-central1.run.app${log.imageUrl}'
                    : null,
              ),
              hieroglyphs: scanHieroglyphs,
              scanLogId: log.id,
            );
            Navigator.push(
              context,
              SmoothRoute(
                type: TransitionType.fadeSlideUp,
                page: BlocProvider.value(
                  value: context.read<ScanCubit>(),
                  child: DetailsView(
                    args: ScanResultArgs(
                      result: response,
                      imagePath: null,
                      isFavorited: log.isFavorited,
                    ),
                  ),
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 78.w,
                    height: 95.h,
                    fit: BoxFit.cover,
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.image_outlined, color: Colors.white54),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final isFavorite = _selectedTabIndex == 0;
    final l10n = AppLocalizations.of(context);
    final appColors = AppColors.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 16.w),
        child: CustomGlassContainer(
          borderRadius: BorderRadius.circular(24.r),
          borderColor: appColors.glassBase.withValues(alpha: 0.05),
          color: appColors.bottomNavBar.withValues(alpha: 0.15),
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFavorite
                      ? Icons.favorite_border_rounded
                      : Icons.document_scanner_outlined,
                  size: 48.r,
                  color: AppColors.secondary,
                ),
              ),
              Gap(16.h),
              Text(
                isFavorite ? l10n.profileNoFavorites : l10n.profileNoScans,
                style: TextStyle(
                  color: appColors.footer.withValues(alpha: 0.75),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              Gap(18.h),

              // Tactile interactive glass shortcut to scan!
            ],
          ),
        ),
      ),
    );
  }
}

/// A high-performance radial gradient orbs background rendering depth layers natively.
class _ProfileBackgroundOrbs extends StatelessWidget {
  const _ProfileBackgroundOrbs();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Orb 1: Primary green gradient glowing sphere at top right
          Positioned(
            top: -40.h,
            right: -100.w,
            width: 280.r,
            height: 280.r,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.16),
                    AppColors.secondary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Orb 2: Dark green/jade glowing sphere at center left
          Positioned(
            top: 280.h,
            left: -120.w,
            width: 250.r,
            height: 250.r,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.08),
                    AppColors.secondary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Orb 3: Soft ambient white glowing sphere near the bottom right
          Positioned(
            bottom: 60.h,
            right: -80.w,
            width: 200.r,
            height: 200.r,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.04),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A premium, stateful avatar widget displaying expandable pulsating aura halos.
class _PulsatingAvatar extends StatefulWidget {
  const _PulsatingAvatar({
    required this.isLoggedIn,
    required this.userName,
    this.imagePath,
    required this.size,
  });

  final bool isLoggedIn;
  final String userName;
  final String? imagePath;
  final double size;

  @override
  State<_PulsatingAvatar> createState() => _PulsatingAvatarState();
}

class _PulsatingAvatarState extends State<_PulsatingAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final letter = widget.userName.trim().isNotEmpty
        ? widget.userName.trim()[0].toUpperCase()
        : '?';

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Double expand outer halo (indicating active, premium connection)
              if (widget.isLoggedIn) ...[
                Transform.scale(
                  scale: 1.0 + 0.15 * _controller.value,
                  child: Container(
                    width: widget.size - 8.r,
                    height: widget.size - 8.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.secondary.withValues(
                          alpha: 0.25 * (1.0 - _controller.value),
                        ),
                        width: 1.5.r,
                      ),
                    ),
                  ),
                ),
              ],
              // Core avatar container
              Container(
                width: widget.size,
                height: widget.size,
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: appColors.background,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(
                        alpha: widget.isLoggedIn ? 0.12 : 0.0,
                      ),
                      blurRadius: 10.r,
                      spreadRadius: 1.r,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.size / 2),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isLoggedIn
                          ? AppColors.secondary.withValues(alpha: 0.15)
                          : appColors.footer.withValues(alpha: 0.8),
                      image: widget.imagePath != null
                          ? DecorationImage(
                              image: ResizeImage(
                                FileImage(File(widget.imagePath!)),
                                width: 150,
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: widget.imagePath == null
                        ? Text(
                            widget.isLoggedIn ? letter : "?",
                            style: TextStyle(
                              fontSize: widget.size * 0.4,
                              height: 1,
                              color: widget.isLoggedIn
                                  ? AppColors.secondary
                                  : appColors.background,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }
}

