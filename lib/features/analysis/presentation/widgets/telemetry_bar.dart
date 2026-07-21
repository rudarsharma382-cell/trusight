import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/analysis_result.dart';

class TelemetryBar extends StatelessWidget {
  final AnalysisResult result;

  const TelemetryBar({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderOverlay),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppTheme.cyanAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                'FORENSIC TELEMETRY BREAKDOWN',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.cyanAccent,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMetricRow('Spatial Residuals', result.spatialArtifactScore),
          const SizedBox(height: 12),
          _buildMetricRow('Spectral Noise Density', result.spectralNoiseScore),
          const SizedBox(height: 12),
          _buildMetricRow('EXIF Metadata Authenticity', result.metadataIntegrityScore, isReversed: true),
          const SizedBox(height: 12),
          _buildMetricRow('Temporal Jitter Index', result.temporalJitterScore),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String title, double value, {bool isReversed = false}) {
    final pct = (value * 100).round();
    // If reversed (like EXIF authenticity), higher is safer (green)
    final color = isReversed
        ? AppTheme.getRiskColor(1.0 - value)
        : AppTheme.getRiskColor(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$pct%',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            backgroundColor: AppTheme.darkSurfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
