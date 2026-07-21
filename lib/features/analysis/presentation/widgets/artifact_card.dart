import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/analysis_result.dart';

class ArtifactCard extends StatelessWidget {
  final ArtifactBreakdown artifact;

  const ArtifactCard({super.key, required this.artifact});

  @override
  Widget build(BuildContext context) {
    final severityColor = AppTheme.getRiskColor(artifact.severityScore);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: artifact.isAnomalyDetected
              ? severityColor.withValues(alpha: 0.3)
              : AppTheme.borderOverlay,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  artifact.category.toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.cyanAccent,
                  ),
                ),
              ),
              // Anomaly status badge
              Row(
                children: [
                  Icon(
                    artifact.isAnomalyDetected
                        ? Icons.report_problem_outlined
                        : Icons.check_circle_outline,
                    size: 16,
                    color: artifact.isAnomalyDetected
                        ? severityColor
                        : AppTheme.emeraldSafe,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    artifact.isAnomalyDetected
                        ? '${(artifact.severityScore * 100).round()}% Anomaly'
                        : 'Passed Integrity',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: artifact.isAnomalyDetected
                          ? severityColor
                          : AppTheme.emeraldSafe,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            artifact.title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            artifact.description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          // Severity indicator bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: artifact.severityScore,
              backgroundColor: AppTheme.darkSurfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(severityColor),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}
