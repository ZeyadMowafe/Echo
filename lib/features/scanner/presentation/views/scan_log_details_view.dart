import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/di/injection_container.dart';
import 'package:echo_explorer/core/helpers/screen_utils.dart';
import 'package:echo_explorer/core/routing/routes.dart';
import 'package:echo_explorer/features/discover/presentation/widgets/custom_discover_app_bar.dart';
import 'package:echo_explorer/features/scanner/domain/entities/scan_log_entity.dart';
import 'package:echo_explorer/features/scanner/presentation/cubit/scan_cubit.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ScanLogDetailsView extends StatefulWidget {
  final ScanLogEntity scanLog;
  const ScanLogDetailsView({super.key, required this.scanLog});

  @override
  State<ScanLogDetailsView> createState() => _ScanLogDetailsViewState();
}

class _ScanLogDetailsViewState extends State<ScanLogDetailsView> {
  late final ScanCubit _cubit;
  late ScanLogEntity _currentLog;

  @override
  void initState() {
    super.initState();
    _currentLog = widget.scanLog;
    _cubit = sl<ScanCubit>();
    _cubit.loadScanLogById(widget.scanLog.id, initialData: widget.scanLog);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.of(context).background,
        body: SafeArea(
          child: Column(
            children: [
              CustomDiscoverAppBar(
                previousState: '',
                title: '',
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: BlocBuilder<ScanCubit, ScanState>(
                  builder: (context, state) {
                    if (state is ScanDetailLoaded) {
                      _currentLog = state.scanLog;
                      return _buildContent(context, _currentLog);
                    }
                    if (state is ScanLoading) {
                      return _buildContent(context, _currentLog);
                    }
                    if (state is ScanFavoritesLoaded) {
                      return _buildContent(context, _currentLog);
                    }
                    if (state is ScanDetailLoading) return _buildLoading(context);
                    if (state is ScanError) return _buildError(context, state.message);
                    return _buildContent(context, _currentLog);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(child: CircularProgressIndicator(color: AppColors.secondary));
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenUtils.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: ScreenUtils.iconXl, color: Colors.redAccent.withValues(alpha: 0.6)),
            Gap(ScreenUtils.md),
            Text(message, style: TextStyle(color: Colors.redAccent, fontSize: 14.sp), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ScanLogEntity log) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: EdgeInsets.all(ScreenUtils.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (log.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
              child: Image.network(
                'https://echo-api-441520148279.me-central1.run.app${log.imageUrl}',
                height: 350.h, width: double.infinity, fit: BoxFit.contain,
              ),
            ),
          Gap(20.h),
          if (log.artifactName != null) ...[
            Text(log.artifactName!, style: TextStyle(
              color: AppColors.of(context).footer,
              fontSize: 22.sp, fontWeight: FontWeight.w700,
            )),
            Gap(ScreenUtils.sm),
          ],
          if (log.description != null) ...[
            Text(log.description!, style: TextStyle(
              color: AppColors.of(context).footer.withValues(alpha: 0.8),
              fontSize: 14.sp, height: 1.5,
            )),
            Gap(ScreenUtils.md),
          ],
          if (log.era != null || log.material != null)
            Wrap(
              spacing: ScreenUtils.sm,
              runSpacing: ScreenUtils.sm,
              children: [
                if (log.era != null)
                  _InfoChip(label: log.era!, icon: Icons.history),
                if (log.material != null)
                  _InfoChip(label: log.material!, icon: Icons.square_outlined),
                if (log.category != null)
                  _InfoChip(label: log.category!, icon: Icons.category_outlined),
                if (log.type != null)
                  _InfoChip(label: log.type!, icon: Icons.image_outlined),
              ],
            ),
          if (log.hieroglyphsTranslation != null) ...[
            Gap(ScreenUtils.lg),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(ScreenUtils.md),
              decoration: BoxDecoration(
                color: AppColors.c151D18.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.secondary, size: ScreenUtils.iconSm),
                      Gap(ScreenUtils.sm),
                      Text(l10n.scanHieroglyphsTranslation,
                          style: TextStyle(color: AppColors.secondary, fontSize: 15.sp, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Gap(12.h),
                  Text(log.hieroglyphsTranslation!, style: TextStyle(
                    color: AppColors.of(context).footer,
                    fontSize: 14.sp, height: 1.6,
                  )),
                ],
              ),
            ),
          ],
          Gap(ScreenUtils.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.read<ScanCubit>().toggleFavoriteScan(log.id),
                  icon: Icon(
                    log.isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: Colors.redAccent, size: ScreenUtils.iconSm,
                  ),
                  label: Text(log.isFavorited ? l10n.scanRemoveFavorites : l10n.scanSaveFavorites,
                      style: TextStyle(color: Colors.redAccent)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                ),
              ),
              Gap(12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.chatView),
                  icon: Icon(Icons.chat_outlined, color: AppColors.secondary, size: ScreenUtils.iconSm),
                  label: Text(l10n.scanChat, style: TextStyle(color: AppColors.secondary)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                ),
              ),
            ],
          ),
          Gap(40.h),
        ],
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
        color: AppColors.c151D18.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.of(context).footer.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: ScreenUtils.iconSm, color: AppColors.secondary),
          Gap(ScreenUtils.xs),
          Text(label, style: TextStyle(
            color: AppColors.of(context).footer.withValues(alpha: 0.7),
            fontSize: 12.sp,
          )),
        ],
      ),
    );
  }
}
