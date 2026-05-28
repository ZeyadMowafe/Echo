import 'dart:io';
import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/di/injection_container.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/core/hive/cache_helper.dart';
import 'package:echo_explorer/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:echo_explorer/features/auth/presentation/widgets/auth_sheet_helper.dart';
import 'package:echo_explorer/core/routing/routes.dart';
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

  @override
  void initState() {
    super.initState();
    _scanCubit = sl<ScanCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authState = context.read<AuthCubit>().state;
      if (authState is! Authenticated) {
        showAuthSheet(
          context,
          AppLocalizations.of(context)!.profileAuthMessage,
        );
        return;
      }
      _loadTabData();
    });
  }

  @override
  void dispose() {
    _scanCubit.close();
    super.dispose();
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
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _scanCubit,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final loggedIn = state is Authenticated;
          final userName = loggedIn ? state.userName : '';
          final userEmail = loggedIn ? state.userEmail : ''; 
          
          final String? profileImagePath = CacheHelper.getData(key: 'profile_image');
          final String? coverImagePath = CacheHelper.getData(key: 'cover_image');

          return ColoredBox(
            color: AppColors.of(context).background,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileHeader(
                    isLoggedIn: loggedIn,
                    userName: userName,
                    profileImagePath: profileImagePath, 
                    coverImagePath: coverImagePath,  
                    onSettings: () {
                      Navigator.of(context).pushNamed(AppRoutes.settingsView);
                    },
                    onEdit: () {
                      if (!loggedIn) {
                        showAuthSheet(context, l10n.profileAuthMessage);
                        return;
                      }
                      Navigator.of(context).pushNamed(AppRoutes.editProfileView);
                    },
                  ),
                  if (loggedIn) ...[
                    Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 0),
                      child: Text(
                        userName,
                        style: TextStyle(
                          color: AppColors.of(context).footer,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                    ),
                    Gap(4.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        userEmail,
                        style: TextStyle(
                          color: AppColors.of(context).footer.withOpacity(0.6),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Gap(20.h),
                    _buildTabs(l10n),
                    Gap(ScreenUtils.md),
                    _buildTabContent(),
                  ],
                Gap(120.h),
              ],
            ),
          ),
        );
      },
      ),
    );
  }

  Widget _buildTabs(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() => _selectedTabIndex = 0);
                  _loadTabData();
                },
                child: Text(
                  l10n.profileFavorite,
                  style: TextStyle(
                    color: _selectedTabIndex == 0 ? AppColors.of(context).footer : AppColors.of(context).footer.withOpacity(0.6),
                    fontSize: 16.sp,
                    fontWeight: _selectedTabIndex == 0 ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              Gap(ScreenUtils.xl),
              GestureDetector(
                onTap: () {
                  setState(() => _selectedTabIndex = 1);
                  _loadTabData();
                },
                child: Text(
                  l10n.profileScan,
                  style: TextStyle(
                    color: _selectedTabIndex == 1 ? AppColors.of(context).footer : AppColors.of(context).footer.withOpacity(0.6),
                    fontSize: 16.sp,
                    fontWeight: _selectedTabIndex == 1 ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        Gap(10.h),
        Divider(
          height: 1.h,
          thickness: 1,
          color: AppColors.of(context).footer.withOpacity(0.12),
        ),
      ],
    );
  }

  Widget _buildTabContent() {
    return BlocBuilder<ScanCubit, ScanState>(
      builder: (context, state) {
        if (state is ScanLoading) {
          return Center(
            child: Padding(
            padding: EdgeInsets.all(ScreenUtils.xl),
            child: CircularProgressIndicator(color: AppColors.secondary),
          ));
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
              child: Text(state.message,
                  style: TextStyle(color: Colors.redAccent, fontSize: 14.sp),
                  textAlign: TextAlign.center),
            ),
          );
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildLogList(List<ScanLogEntity> logs) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtils.md),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          final name = log.artifactName ?? log.artifactModelId ?? 'Unknown Artifact';
          return Card(
            color: AppColors.c151D18.withValues(alpha: 0.6),
            margin: EdgeInsets.symmetric(vertical: 4.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ScreenUtils.radiusSm),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              leading: Icon(Icons.image_outlined, color: AppColors.secondary, size: ScreenUtils.iconMd),
              title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.cf9f9f9, fontSize: 15.sp)),
              subtitle: Text(
                '${log.era ?? 'Unknown'} • ${DateTime.now().difference(log.createdAt).inDays}d ago',
                style: TextStyle(color: AppColors.cf9f9f9.withValues(alpha: 0.5), fontSize: 12.sp),
              ),
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
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ScanCubit>(),
                    child: DetailsView(
                      args: ScanResultArgs(
                        result: response,
                        imagePath: null,
                      ),
                    ),
                  ),
                ));
              },
              trailing: IconButton(
                icon: Icon(
                  log.isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: log.isFavorited ? Colors.redAccent : AppColors.cf9f9f9.withValues(alpha: 0.3),
                  size: ScreenUtils.iconSm,
                ),
                onPressed: () => context.read<ScanCubit>().toggleFavoriteScan(log.id),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final isFavorite = _selectedTabIndex == 0;
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenUtils.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFavorite ? Icons.favorite_border_rounded : Icons.document_scanner_outlined,
              size: 64.r,
              color: AppColors.of(context).footer.withOpacity(0.2),
            ),
            Gap(ScreenUtils.md),
            Text(
              isFavorite ? l10n.profileNoFavorites : l10n.profileNoScans,
              style: TextStyle(
                color: AppColors.of(context).footer.withOpacity(0.5),
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.isLoggedIn,
    required this.userName,
    this.profileImagePath,
    this.coverImagePath,
    required this.onSettings,
    required this.onEdit,
  });

  final bool isLoggedIn;
  final String userName;
  final String? profileImagePath;
  final String? coverImagePath;
  final VoidCallback onSettings;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: 190.h, 
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 124.h,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1B2328),
                image: coverImagePath != null
                    ? DecorationImage(
                        image: FileImage(File(coverImagePath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
          ),
          Positioned(
            right: 12.w,
            top: topPad + 4.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _HeaderIconButton(icon: Icons.settings_outlined, onTap: onSettings),
                Gap(6.h),
                _HeaderIconButton(icon: Icons.edit_outlined, onTap: onEdit),
              ],
            ),
          ),
          Positioned(
            left: 16.w,
            top: 69.h,
            child: _AvatarChip(isLoggedIn: isLoggedIn, userName: userName, imagePath: profileImagePath),
          ),
        ],
      ),
    );
  }
}

class _AvatarChip extends StatelessWidget {
  const _AvatarChip({required this.isLoggedIn, required this.userName, this.imagePath});
  final bool isLoggedIn;
  final String userName;
  final String? imagePath;

  String get _letter {
    final t = userName.trim();
    if (t.isEmpty) return '?';
    return t[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Container(
        padding: EdgeInsets.all(5.r),
        decoration: BoxDecoration(color:AppColors.of(context).background, shape: BoxShape.circle),
        child:CircleAvatar(
          radius: 52.r,
          backgroundColor: AppColors.of(context).footer,
          child: Icon(Icons.person_outline, size: 40.r, color: AppColors.of(context).background),
        ),
      );
    }
    return Container(
      width: 110.r,
      height: 110.r,
      padding: EdgeInsets.all(5.r),
      decoration: BoxDecoration(color: AppColors.of(context).background, shape: BoxShape.circle),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.of(context).footer,
          shape: BoxShape.circle,
          image: imagePath != null ? DecorationImage(image: FileImage(File(imagePath!)), fit: BoxFit.cover) : null,
        ),
        alignment: Alignment.center,
        child: imagePath == null ? Text(_letter, style:  TextStyle(fontSize: 56.sp, height: 1, color: AppColors.of(context).background, fontWeight: FontWeight.w600)) : null,
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          width: 38.r,
          height: 38.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.c000000.withOpacity(0), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.cffffff, size: ScreenUtils.iconSm),
        ),
      ),
    );
  }
}