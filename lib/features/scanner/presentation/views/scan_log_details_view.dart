import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/di/injection_container.dart';
import 'package:echo_explorer/core/routing/routes.dart';
import 'package:echo_explorer/features/discover/presentation/widgets/custom_discover_app_bar.dart';
import 'package:echo_explorer/features/scanner/domain/entities/scan_log_entity.dart';
import 'package:echo_explorer/features/scanner/presentation/cubit/scan_cubit.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                      print('=== DetailsView: ScanDetailLoaded isFavorited=${state.scanLog.isFavorited} ===');
                      _currentLog = state.scanLog;
                      return _buildContent(context, _currentLog);
                    }
                    if (state is ScanLoading) {
                      print('=== DetailsView: ScanLoading, keeping _currentLog.isFavorited=${_currentLog.isFavorited} ===');
                      return _buildContent(context, _currentLog);
                    }
                    if (state is ScanFavoritesLoaded) {
                      print('=== DetailsView: ScanFavoritesLoaded, keeping _currentLog.isFavorited=${_currentLog.isFavorited} ===');
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.redAccent.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text(message, style: TextStyle(color: Colors.redAccent, fontSize: 14), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ScanLogEntity log) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (log.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                'https://echo-api-441520148279.me-central1.run.app${log.imageUrl}',
                height: 350, width: double.infinity, fit: BoxFit.contain,
              ),
            ),
          const SizedBox(height: 20),
          if (log.artifactName != null) ...[
            Text(log.artifactName!, style: TextStyle(
              color: AppColors.of(context).footer,
              fontSize: 22, fontWeight: FontWeight.w700,
            )),
            const SizedBox(height: 8),
          ],
          if (log.description != null) ...[
            Text(log.description!, style: TextStyle(
              color: AppColors.of(context).footer.withValues(alpha: 0.8),
              fontSize: 14, height: 1.5,
            )),
            const SizedBox(height: 16),
          ],
          if (log.era != null || log.material != null)
            Wrap(
              spacing: 8,
              runSpacing: 8,
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
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.c151D18.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.secondary, size: 18),
                      const SizedBox(width: 8),
                      Text(l10n.scanHieroglyphsTranslation,
                          style: TextStyle(color: AppColors.secondary, fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(log.hieroglyphsTranslation!, style: TextStyle(
                    color: AppColors.of(context).footer,
                    fontSize: 14, height: 1.6,
                  )),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.read<ScanCubit>().toggleFavoriteScan(log.id),
                  icon: Icon(
                    log.isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: Colors.redAccent, size: 20,
                  ),
                  label: Text(log.isFavorited ? l10n.scanRemoveFavorites : l10n.scanSaveFavorites,
                      style: TextStyle(color: Colors.redAccent)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.chatView),
                  icon: Icon(Icons.chat_outlined, color: AppColors.secondary, size: 20),
                  label: Text(l10n.scanChat, style: TextStyle(color: AppColors.secondary)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.c151D18.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.of(context).footer.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.secondary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(
            color: AppColors.of(context).footer.withValues(alpha: 0.7),
            fontSize: 12,
          )),
        ],
      ),
    );
  }
}
