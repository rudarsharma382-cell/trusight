import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/analysis_result.dart';

class ExportReportModal extends StatelessWidget {
  final AnalysisResult result;

  const ExportReportModal({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final jsonReport = const JsonEncoder.withIndent('  ').convert(result.toJson());

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 95,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.darkCardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.security_rounded, color: AppTheme.cyanAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Forensic Audit Report',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Scan Identifier: ${result.id} | Timestamp: ${result.timestamp.toIso8601String()}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.darkBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderOverlay),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  jsonReport,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    color: AppTheme.cyanAccent,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: jsonReport));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Forensic JSON report copied to clipboard!'),
                        backgroundColor: AppTheme.cyanAccent,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy JSON'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Exporting Forensic Summary PDF / Certificate...'),
                        backgroundColor: AppTheme.emeraldSafe,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Export Summary'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
