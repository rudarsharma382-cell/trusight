import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/media_validators.dart';
import '../../../analysis/data/models/analysis_result.dart';
import '../../../analysis/presentation/screens/export_report_modal.dart';
import '../../../analysis/presentation/widgets/confidence_gauge.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyProvider);
    final notifier = ref.read(historyProvider.notifier);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B10).withValues(alpha: 0.95),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/trusight_logo.png',
                height: 26,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.radar_rounded,
                  color: AppTheme.electricCyan,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Audit Log & History',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          if (state.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.textMuted),
              tooltip: 'Clear History',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF141C2B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    title: Text(
                      'Clear Scan History?',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                      'Are you sure you want to delete all past forensic scan records?',
                      style: GoogleFonts.inter(color: AppTheme.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.dangerRed,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          notifier.clearHistory();
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          'Clear All',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Pinned Search & Category Filter Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search Input
                    GlassContainer(
                      borderRadius: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      child: TextField(
                        onChanged: (val) => notifier.setSearchQuery(val),
                        style: GoogleFonts.inter(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search file name or classification...',
                          hintStyle: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.electricCyan, size: 20),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: Colors.transparent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Category Filter Horizontal Chips
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildFilterChip(
                            label: 'All Media',
                            isSelected: state.selectedCategory == null,
                            onTap: () => notifier.setFilterCategory(null),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Images',
                            isSelected: state.selectedCategory == MediaTypeCategory.image,
                            onTap: () => notifier.setFilterCategory(MediaTypeCategory.image),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Videos',
                            isSelected: state.selectedCategory == MediaTypeCategory.video,
                            onTap: () => notifier.setFilterCategory(MediaTypeCategory.video),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Audio',
                            isSelected: state.selectedCategory == MediaTypeCategory.audio,
                            onTap: () => notifier.setFilterCategory(MediaTypeCategory.audio),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Scan History List / Empty View
              Expanded(
                child: state.items.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Styled Glowing Container with TruSight Logo Asset
                              Container(
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF141C2B).withValues(alpha: 0.9),
                                  border: Border.all(
                                    color: AppTheme.electricCyan.withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.electricCyan.withValues(alpha: 0.25),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.visibility_outlined,
                                  size: 48,
                                  color: AppTheme.electricCyan,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'No Recent Scans',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // High-Tech Styled Subtitle Glass Section Box
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF131A26).withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppTheme.electricCyan.withValues(alpha: 0.25),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.info_outline_rounded, color: AppTheme.electricCyan, size: 16),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Scan an image, video, or audio file to log records',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),
                              _buildPoweredByFooter(),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 88),
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return _buildHistoryGlassCard(context, item);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    AppTheme.electricCyan,
                    AppTheme.neonIndigo,
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.electricCyan.withValues(alpha: 0.3),
                    blurRadius: 10,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.black : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryGlassCard(BuildContext context, AnalysisResult item) {
    final riskColor = AppTheme.getRiskColor(item.overallScore);

    return GlassContainer(
      borderRadius: 20,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          showModalBottomSheet(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: AppTheme.darkBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    'Historical Scan (${item.id})',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: ConfidenceGauge(
                          score: item.overallScore,
                          classification: item.classification,
                        ),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => SizedBox(
                              height: MediaQuery.of(context).size.height * 0.75,
                              child: ExportReportModal(result: item),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Export JSON Telemetry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.electricCyan.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.electricCyan.withValues(alpha: 0.25)),
          ),
          child: Icon(
            item.mediaType == MediaTypeCategory.image
                ? Icons.image_outlined
                : item.mediaType == MediaTypeCategory.video
                    ? Icons.videocam_outlined
                    : Icons.graphic_eq_rounded,
            color: AppTheme.electricCyan,
            size: 22,
          ),
        ),
        title: Text(
          item.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${item.classification} • ${MediaValidators.formatBytes(item.fileSizeBytes)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: riskColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.timestamp.toString().split('.').first,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: riskColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: riskColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            '${item.riskPercentage}%',
            style: GoogleFonts.plusJakartaSans(
              color: riskColor,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPoweredByFooter() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF131A26).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.electricCyan.withValues(alpha: 0.25),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.electricCyan,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.electricCyan,
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Powered by Rudar Sharma',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.electricCyan,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
