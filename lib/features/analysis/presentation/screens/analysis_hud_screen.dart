import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/media_validators.dart';
import '../providers/analysis_provider.dart';
import '../widgets/artifact_card.dart';
import '../widgets/confidence_gauge.dart';
import '../widgets/telemetry_bar.dart';
import 'export_report_modal.dart';

class AnalysisHUDScreen extends ConsumerWidget {
  final VoidCallback? onScanAnother;

  const AnalysisHUDScreen({super.key, this.onScanAnother});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analysisProvider);
    final result = state.result;

    if (result == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: Center(
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
                const SizedBox(height: 6),
                Text(
                  'Select an image, video, or audio clip to perform a scan.',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white54),
                ),
                const SizedBox(height: 24),
                if (onScanAnother != null)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.electricCyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: onScanAnother,
                    icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    label: Text(
                      'Go to Detector',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

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
              'Forensic HUD (${result.id})',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppTheme.electricCyan),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: ExportReportModal(result: result),
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // File Header Info Card
                GlassContainer(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.electricCyan.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.electricCyan.withValues(alpha: 0.25)),
                        ),
                        child: Icon(
                          result.mediaType == MediaTypeCategory.image
                              ? Icons.image_outlined
                              : result.mediaType == MediaTypeCategory.video
                                  ? Icons.videocam_outlined
                                  : Icons.graphic_eq_rounded,
                          color: AppTheme.electricCyan,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result.fileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${result.mediaType.name.toUpperCase()} • ${MediaValidators.formatBytes(result.fileSizeBytes)}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Central Confidence Radial Gauge
                Center(
                  child: ConfidenceGauge(
                    score: result.overallScore,
                    classification: result.classification,
                  ),
                ),
                const SizedBox(height: 28),

                // Telemetry Bar
                TelemetryBar(result: result),
                const SizedBox(height: 24),

                // Detected Forensic Signals Section
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.electricCyan,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'DETECTED FORENSIC ARTIFACTS (${result.artifacts.length})',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.electricCyan,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...result.artifacts.map((artifact) => ArtifactCard(artifact: artifact)),

                const SizedBox(height: 28),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.electricCyan,
                          side: const BorderSide(color: AppTheme.electricCyan, width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => SizedBox(
                              height: MediaQuery.of(context).size.height * 0.75,
                              child: ExportReportModal(result: result),
                            ),
                          );
                        },
                        icon: const Icon(Icons.file_present_outlined, size: 18),
                        label: Text(
                          'Export Telemetry',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.electricCyan,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          ref.read(analysisProvider.notifier).clearSelection();
                          if (onScanAnother != null) {
                            onScanAnother!();
                          }
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(
                          'Scan Another',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
