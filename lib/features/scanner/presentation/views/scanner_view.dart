import 'dart:io';
import 'package:echo_explorer/core/constants/app_colors.dart';
import 'package:echo_explorer/core/constants/app_strings.dart';
import 'package:echo_explorer/core/di/injection_container.dart';
import 'package:echo_explorer/features/chat/presentation/views/chat_view.dart';
import 'package:echo_explorer/features/discover/presentation/widgets/custom_discover_app_bar.dart';
import 'package:echo_explorer/features/scanner/presentation/cubit/scan_cubit.dart';
import 'package:echo_explorer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ScannerView extends StatelessWidget {
  const ScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ScanCubit>(),
      child: _ScannerBody(),
    );
  }
}

class _ScannerBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: SafeArea(
        child: Column(
          children: [
            CustomDiscoverAppBar(
              previousState: AppStrings.scanFeature.key,
              title: '',
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: BlocBuilder<ScanCubit, ScanState>(
                builder: (context, state) {
                  if (state is ScanInitial) return _buildHome(context);
                  if (state is ScanImagePicked) return _buildPreview(context, state);
                  if (state is ScanLoading) return _buildLoading(context);
                  if (state is ScanResultLoaded) return _buildResult(context, state);
                  if (state is ScanError) return _buildError(context, state);
                  return _buildHome(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHome(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 80,
                color: AppColors.of(context).footer.withValues(alpha: 0.2)),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.scanTitle,
              style: TextStyle(
                color: AppColors.of(context).footer,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.scanSubtitle,
              style: TextStyle(
                color: AppColors.of(context).footer.withValues(alpha: 0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _ScanButton(
              icon: Icons.camera_alt_rounded,
              label: AppLocalizations.of(context)!.scanTakePhoto,
              onTap: () => _pickImage(context, ImageSource.camera),
            ),
            const SizedBox(height: 16),
            _ScanButton(
              icon: Icons.photo_library_outlined,
              label: AppLocalizations.of(context)!.scanPickGallery,
              onTap: () => _pickImage(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source);
    if (file != null && context.mounted) {
      context.read<ScanCubit>().setImagePath(file.path);
    }
  }

  Future<void> _saveToFavorites(BuildContext context, String scanLogId) async {
    final cubit = context.read<ScanCubit>();
    final wasFavorited = cubit.state is ScanResultLoaded && (cubit.state as ScanResultLoaded).isFavorited;
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
                const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                const SizedBox(width: 12),
                Text(l10n.scanAddedToFavorites, style: const TextStyle(color: Colors.white)),
              ],
            ),
            backgroundColor: AppColors.c151D18,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                const Icon(Icons.favorite_border, color: Colors.grey, size: 20),
                const SizedBox(width: 12),
                Text(l10n.scanRemovedFromFavorites, style: const TextStyle(color: Colors.white)),
              ],
            ),
            backgroundColor: AppColors.c151D18,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(milliseconds: 1200),
          ),
        );
      }
    }
  }

  Widget _buildPreview(BuildContext context, ScanImagePicked state) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(File(state.imagePath), height: 400, width: double.infinity, fit: BoxFit.contain),
          ),
          const SizedBox(height: 24),
          _ScanButton(
            icon: Icons.search_rounded,
            label: l10n.scanAnalyzeArtifact,
            onTap: () => context.read<ScanCubit>().analyzeImage(),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => context.read<ScanCubit>().clearResult(),
            icon: Icon(Icons.refresh, color: AppColors.of(context).footer.withValues(alpha: 0.5)),
            label: Text(l10n.scanDifferentPhoto,
                style: TextStyle(color: AppColors.of(context).footer.withValues(alpha: 0.5))),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.secondary),
          const SizedBox(height: 24),
          Text(
            l10n.scanAnalyzing,
            style: TextStyle(
              color: AppColors.of(context).footer,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.scanAnalyzingWait,
            style: TextStyle(
              color: AppColors.of(context).footer.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context, ScanResultLoaded state) {
    final l10n = AppLocalizations.of(context)!;
    final result = state.result;
    final artifact = result.artifact;
    final hieroglyphs = result.hieroglyphs;
    print('=== ScannerView _buildResult: hieroglyphs=${hieroglyphs?.translation}, detected=${hieroglyphs?.detected} ===');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with favorite overlay
          if (state.imagePath != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(File(state.imagePath!), height: 350, width: double.infinity, fit: BoxFit.contain),
                ),
                if (result.scanLogId != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => _saveToFavorites(context, result.scanLogId!),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.c151D18.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          state.isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: state.isFavorited ? Colors.redAccent : Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 20),

          // Artifact name + favorite inline
          if (artifact.name != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(artifact.name!, style: TextStyle(
                    color: AppColors.of(context).footer,
                    fontSize: 22, fontWeight: FontWeight.w700,
                  )),
                ),
                if (result.scanLogId != null) ...[
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _saveToFavorites(context, result.scanLogId!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: state.isFavorited
                            ? Colors.redAccent.withValues(alpha: 0.15)
                            : AppColors.c151D18.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: state.isFavorited
                              ? Colors.redAccent.withValues(alpha: 0.4)
                              : AppColors.of(context).footer.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            state.isFavorited ? Icons.favorite : Icons.favorite_border,
                            color: state.isFavorited ? Colors.redAccent : AppColors.of(context).footer.withValues(alpha: 0.5),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            state.isFavorited ? l10n.scanFavorited : l10n.scanSave,
                            style: TextStyle(
                              color: state.isFavorited ? Colors.redAccent : AppColors.of(context).footer.withValues(alpha: 0.6),
                              fontSize: 13, fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),

          // Info chips
          if (artifact.era != null || artifact.material != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (artifact.era != null)
                  _InfoChip(label: artifact.era!, icon: Icons.history),
                if (artifact.material != null)
                  _InfoChip(label: artifact.material!, icon: Icons.square_outlined),
                if (artifact.category != null)
                  _InfoChip(label: artifact.category!, icon: Icons.category_outlined),
                if (artifact.type != null)
                  _InfoChip(label: artifact.type!, icon: Icons.image_outlined),
              ],
            ),
          ],

          // Description
          if (artifact.description != null) ...[
            const SizedBox(height: 16),
            Text(artifact.description!, style: TextStyle(
              color: AppColors.of(context).footer.withValues(alpha: 0.8),
              fontSize: 14, height: 1.5,
            )),
          ],

          // Hieroglyphs
          if (hieroglyphs != null && hieroglyphs.detected && hieroglyphs.translation != null) ...[
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
                  Text(hieroglyphs.translation!, style: TextStyle(
                    color: AppColors.of(context).footer,
                    fontSize: 14, height: 1.6,
                  )),
                  if (hieroglyphs.totalLines != null || hieroglyphs.totalGlyphs != null) ...[
                    const SizedBox(height: 12),
                    Divider(color: AppColors.of(context).footer.withValues(alpha: 0.1)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (hieroglyphs.totalLines != null)
                          _StatChip('${hieroglyphs.totalLines} lines', Icons.horizontal_rule),
                        if (hieroglyphs.totalGlyphs != null)
                          _StatChip('${hieroglyphs.totalGlyphs} glyphs', Icons.text_fields),
                        if (hieroglyphs.cartoucheCount != null)
                          _StatChip('${hieroglyphs.cartoucheCount} cartouches', Icons.circle_outlined),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (hieroglyphs != null && !hieroglyphs.detected) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.c151D18.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.of(context).footer.withValues(alpha: 0.5), size: 18),
                  const SizedBox(width: 8),
                  Text(l10n.scanNoHieroglyphs,
                      style: TextStyle(color: AppColors.of(context).footer.withValues(alpha: 0.5))),
                ],
              ),
            ),
          ],

          // Bottom actions
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (hieroglyphs != null && (hieroglyphs.translation?.isNotEmpty == true))
                  _ActionButton(
                    icon: Icons.auto_awesome,
                    label: l10n.scanHieroglyphs,
                    color: AppColors.secondary,
                    onTap: () => _showHieroglyphsSheet(context, hieroglyphs.translation ?? ''),
                  ),
                _ActionButton(
                  icon: Icons.refresh,
                  label: l10n.scanNewScan,
                  color: AppColors.of(context).footer.withValues(alpha: 0.6),
                  onTap: () => context.read<ScanCubit>().clearResult(),
                ),
                if (artifact.artifactModelId != null)
                  _ActionButton(
                    icon: Icons.chat_outlined,
                    label: l10n.scanChat,
                    color: AppColors.secondary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatView(
                            artifactId: artifact.artifactModelId,
                            artifactName: artifact.name ?? artifact.artifactModelId,
                          ),
                        ),
                      );
                    },
                  ),
            ],
          ),
          const SizedBox(height: 40),
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
        height: MediaQuery.of(ctx).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.c151D18,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.of(ctx).footer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.secondary, size: 22),
                  const SizedBox(width: 10),
                  Text(l10n.scanHieroglyphsTranslation,
                      style: TextStyle(color: AppColors.secondary, fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Divider(color: AppColors.of(ctx).footer.withValues(alpha: 0.1)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: SelectableText(translation, style: TextStyle(
                  color: AppColors.of(ctx).footer,
                  fontSize: 16, height: 1.8,
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, ScanError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64,
                color: Colors.redAccent.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text(state.message,
                style: TextStyle(color: Colors.redAccent, fontSize: 15),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            _ScanButton(
              icon: Icons.refresh,
              label: 'Try Again',
              onTap: () => context.read<ScanCubit>().clearResult(),
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
  const _ScanButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
          foregroundColor: AppColors.secondary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
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

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _StatChip(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.of(context).footer.withValues(alpha: 0.5)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(
            color: AppColors.of(context).footer.withValues(alpha: 0.6),
            fontSize: 12,
          )),
        ],
      ),
    );
  }
}
