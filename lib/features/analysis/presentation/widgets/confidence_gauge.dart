import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/theme/app_theme.dart';

class ConfidenceGauge extends StatelessWidget {
  final double score; // 0.0 to 1.0
  final String classification;
  final double radius;

  const ConfidenceGauge({
    super.key,
    required this.score,
    required this.classification,
    this.radius = 110.0,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getRiskColor(score / 100.0);
    final percentage = score.round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularPercentIndicator(
          radius: radius,
          lineWidth: 16.0,
          animation: true,
          animationDuration: 1200,
          percent: (score / 100.0).clamp(0.0, 1.0),
          circularStrokeCap: CircularStrokeCap.round,
          backgroundColor: AppTheme.borderOverlay.withValues(alpha: 0.5),
          progressColor: color,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$percentage%',
                style: GoogleFonts.outfit(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'SYNTHETIC RISK',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  score < 0.35
                      ? Icons.verified_user_rounded
                      : score < 0.70
                          ? Icons.warning_amber_rounded
                          : Icons.gpp_bad_rounded,
                  color: color,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  classification.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
