import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/media_validators.dart';
import '../../../analysis/presentation/providers/analysis_provider.dart';
import '../../../analysis/presentation/widgets/progress_hud.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../widgets/audio_preview_player.dart';
import '../widgets/media_drop_zone.dart';
import '../widgets/media_type_selector.dart';
import '../widgets/video_preview_player.dart';

class MediaPickerScreen extends ConsumerWidget {
  final VoidCallback onNavigateToResults;

  const MediaPickerScreen({super.key, required this.onNavigateToResults});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analysisProvider);
    final notifier = ref.read(analysisProvider.notifier);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B10).withValues(alpha: 0.95),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Clean Logo Mark (height: 24)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/trusight_logo.png',
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.radar_rounded,
                  color: AppTheme.electricCyan,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'TruSight',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Ambient Background Light Glow Orbs
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.electricCyan.withValues(alpha: 0.08),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.electricCyan.withValues(alpha: 0.08),
                      blurRadius: 100,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.neonIndigo.withValues(alpha: 0.07),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonIndigo.withValues(alpha: 0.07),
                      blurRadius: 120,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),

            // Scrollable Main Content
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Subtitle Section with Flexible Text Protection
                    Row(
                      children: [
                        const AnimatedGlowDot(color: AppTheme.electricCyan),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI MEDIA FORENSICS DETECTOR',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.electricCyan,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          AppTheme.electricCyan,
                          Color(0xFFA855F7),
                          AppTheme.neonIndigo,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds),
                      child: Text(
                        'Verify Media Authenticity',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Detect synthetic artifacts, deepfakes, and AI audio in seconds.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Glass Pill Category Selector Tab Bar (Image / Video / Audio)
                    MediaTypeSelector(
                      selectedCategory: state.category,
                      onCategoryChanged: (cat) => notifier.setCategory(cat),
                    ),
                    const SizedBox(height: 24),

                    // Hero Drop Zone or Media Preview Card
                    if (state.selectedFile == null)
                      MediaDropZone(
                        category: state.category,
                        onFileSelected: (file) async {
                          notifier.setSelectedFile(file);
                          await notifier.runAnalysis(file: file);
                          final newState = ref.read(analysisProvider);
                          if (newState.status == AnalysisStatus.success && newState.result != null) {
                            ref.read(historyProvider.notifier).addScan(newState.result!);
                            onNavigateToResults();
                          }
                        },
                      )
                    else
                      _buildMediaPreviewCard(context, ref, state.selectedFile!, state.category),

                    const SizedBox(height: 24),

                    // Error Message Banner
                    if (state.errorMessage != null)
                      GlassContainer(
                        borderRadius: 16,
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(14),
                        color: AppTheme.dangerRed.withValues(alpha: 0.12),
                        border: Border.all(
                          color: AppTheme.dangerRed.withValues(alpha: 0.4),
                          width: 1,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppTheme.dangerRed, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.errorMessage!,
                                style: GoogleFonts.inter(
                                  color: AppTheme.dangerRed,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Execute Scan Glass Button
                    if (state.selectedFile != null)
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.electricCyan.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: state.isLoading
                                ? null
                                : () async {
                                    await notifier.runAnalysis();
                                    final newState = ref.read(analysisProvider);
                                    if (newState.status == AnalysisStatus.success && newState.result != null) {
                                      ref.read(historyProvider.notifier).addScan(newState.result!);
                                      onNavigateToResults();
                                    }
                                  },
                            borderRadius: BorderRadius.circular(28),
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.electricCyan,
                                    AppTheme.neonIndigo,
                                  ],
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.fingerprint_rounded,
                                    size: 24,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'EXECUTE MEDIA SCAN',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Continuous Horizontal Engine Cards ("DETECTION ENGINES ACTIVE")
                    _buildHorizontalActiveEngineSection(),
                    const SizedBox(height: 12),

                    // Powered by Rudar Sharma Footer
                    _buildPoweredByFooter(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Loading Progress HUD Overlay
            if (state.isLoading) ProgressHUD(state: state),
          ],
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

  Widget _buildMediaPreviewCard(
    BuildContext context,
    WidgetRef ref,
    File file,
    MediaTypeCategory category,
  ) {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final fileSize = file.existsSync() ? file.lengthSync() : 0;

    return GlassContainer(
      borderRadius: 24,
      border: Border.all(
        color: AppTheme.electricCyan.withValues(alpha: 0.4),
        width: 1.2,
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 0.8,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppTheme.mintGreen, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    MediaValidators.formatBytes(fileSize),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: AppTheme.textMuted, size: 20),
                  onPressed: () => ref.read(analysisProvider.notifier).clearSelection(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ScanningLineOverlay(
              child: category == MediaTypeCategory.image
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 240,
                        width: double.infinity,
                        child: Image.file(
                          file,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Text('Image Loaded (Preview unavailable)'),
                          ),
                        ),
                      ),
                    )
                  : category == MediaTypeCategory.video
                      ? VideoPreviewPlayer(file: file)
                      : AudioPreviewPlayer(file: file),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalActiveEngineSection() {
    final List<Map<String, dynamic>> engines = [
      {
        'icon': Icons.psychology_outlined,
        'title': 'Diffusion Noise',
        'sub': 'Flux & SD Latents',
        'color': AppTheme.electricCyan,
      },
      {
        'icon': Icons.graphic_eq_outlined,
        'title': 'Phase Spectrum',
        'sub': 'Vocoder Cutoffs',
        'color': AppTheme.cyberPurple,
      },
      {
        'icon': Icons.subtitles_outlined,
        'title': 'Deepfake Video',
        'sub': 'Optical Flow & Mesh',
        'color': AppTheme.neonIndigo,
      },
      {
        'icon': Icons.fingerprint_rounded,
        'title': 'Spectral EXIF',
        'sub': 'Metadata & Hashes',
        'color': AppTheme.mintGreen,
      },
      {
        'icon': Icons.hub_outlined,
        'title': 'Latent Vector',
        'sub': 'Manifold Inspection',
        'color': AppTheme.warningAmber,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const AnimatedGlowDot(color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'DETECTION ENGINES',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: Colors.white70,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3), width: 0.8),
              ),
              child: Text(
                '5 ACTIVE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 115,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: engines.length,
            itemBuilder: (context, index) {
              final engine = engines[index];
              return Padding(
                padding: EdgeInsets.only(right: index == engines.length - 1 ? 0 : 12),
                child: GlassContainer(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(14),
                  child: SizedBox(
                    width: 160,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (engine['color'] as Color).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                engine['icon'] as IconData,
                                color: engine['color'] as Color,
                                size: 18,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.mintGreen,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Active',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.mintGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              engine['title'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              engine['sub'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Subtle Pulsing Indicator Dot
class AnimatedGlowDot extends StatefulWidget {
  final Color color;

  const AnimatedGlowDot({super.key, this.color = const Color(0xFF10B981)});

  @override
  State<AnimatedGlowDot> createState() => _AnimatedGlowDotState();
}

class _AnimatedGlowDotState extends State<AnimatedGlowDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: _animation.value),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _animation.value * 0.8),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Animated High-Tech Laser Scanning Line Overlay
class ScanningLineOverlay extends StatefulWidget {
  final Widget child;

  const ScanningLineOverlay({super.key, required this.child});

  @override
  State<ScanningLineOverlay> createState() => _ScanningLineOverlayState();
}

class _ScanningLineOverlayState extends State<ScanningLineOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _scanController,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment(0, (_scanController.value * 2.0) - 1.0),
                heightFactor: 0.06,
                widthFactor: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.electricCyan.withValues(alpha: 0.0),
                        AppTheme.electricCyan.withValues(alpha: 0.7),
                        AppTheme.electricCyan.withValues(alpha: 0.0),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.electricCyan.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
