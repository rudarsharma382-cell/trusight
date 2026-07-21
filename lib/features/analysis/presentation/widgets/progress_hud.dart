import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/analysis_provider.dart';

class ProgressHUD extends StatelessWidget {
  final AnalysisState state;

  const ProgressHUD({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.darkBackground.withValues(alpha: 0.95),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SpinKitCubeGrid(
                color: AppTheme.cyanAccent,
                size: 64.0,
              ),
              const SizedBox(height: 36),
              Text(
                'TRUSIGHT DEEP DETECTION ENGINE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.cyanAccent,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                state.statusMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: state.progress,
                  backgroundColor: AppTheme.darkSurfaceVariant,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.cyanAccent),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${(state.progress * 100).round()}% Completed',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
