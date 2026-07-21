import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/media_validators.dart';

class MediaDropZone extends StatefulWidget {
  final MediaTypeCategory category;
  final ValueChanged<File> onFileSelected;

  const MediaDropZone({
    super.key,
    required this.category,
    required this.onFileSelected,
  });

  @override
  State<MediaDropZone> createState() => _MediaDropZoneState();
}

class _MediaDropZoneState extends State<MediaDropZone> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    XFile? picked;

    if (widget.category == MediaTypeCategory.image) {
      picked = await picker.pickImage(source: ImageSource.gallery);
    } else if (widget.category == MediaTypeCategory.video) {
      picked = await picker.pickVideo(source: ImageSource.gallery);
    } else {
      await _pickFromFiles(context);
      return;
    }

    if (picked != null) {
      widget.onFileSelected(File(picked.path));
    }
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    final picker = ImagePicker();
    XFile? picked;

    if (widget.category == MediaTypeCategory.image) {
      picked = await picker.pickImage(source: ImageSource.camera);
    } else if (widget.category == MediaTypeCategory.video) {
      picked = await picker.pickVideo(source: ImageSource.camera);
    } else {
      await _pickFromFiles(context);
      return;
    }

    if (picked != null) {
      widget.onFileSelected(File(picked.path));
    }
  }

  Future<void> _pickFromFiles(BuildContext context) async {
    FileType type = FileType.any;
    List<String>? allowedExts;

    if (widget.category == MediaTypeCategory.image) {
      type = FileType.custom;
      allowedExts = MediaValidators.supportedImageExtensions;
    } else if (widget.category == MediaTypeCategory.video) {
      type = FileType.custom;
      allowedExts = MediaValidators.supportedVideoExtensions;
    } else if (widget.category == MediaTypeCategory.audio) {
      type = FileType.custom;
      allowedExts = MediaValidators.supportedAudioExtensions;
    }

    final result = await FilePicker.pickFiles(
      type: type,
      allowedExtensions: allowedExts,
    );

    if (result != null && result.files.single.path != null) {
      widget.onFileSelected(File(result.files.single.path!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.category == MediaTypeCategory.image
        ? 'Select Image'
        : widget.category == MediaTypeCategory.video
            ? 'Select Video'
            : 'Select Audio';

    final subtitle = widget.category == MediaTypeCategory.image
        ? 'Scan for AI diffusion patterns and EXIF metadata anomalies'
        : widget.category == MediaTypeCategory.video
            ? 'Analyze temporal frame continuity and facial optical flow'
            : 'Inspect vocoder frequency limits and spectral phase data';

    final formatsText = widget.category == MediaTypeCategory.image
        ? 'JPG, PNG, WEBP • Max 100MB'
        : widget.category == MediaTypeCategory.video
            ? 'MP4, MOV • Auto-compressed'
            : 'MP3, WAV, AAC, M4A';

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final glowOpacity = _pulseAnimation.value;

        return GlassContainer(
          borderRadius: 32,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          border: Border.all(
            color: AppTheme.electricCyan.withValues(alpha: 0.15 + (glowOpacity * 0.25)),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.electricCyan.withValues(alpha: glowOpacity * 0.12),
              blurRadius: 28,
              spreadRadius: -4,
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Radial Ambient Glowing Hero Icon & Brand Container
              Transform.scale(
                scale: 0.98 + (glowOpacity * 0.04),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.electricCyan.withValues(alpha: glowOpacity * 0.35),
                            AppTheme.neonIndigo.withValues(alpha: glowOpacity * 0.1),
                            Colors.transparent,
                          ],
                          radius: 0.85,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(18),
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
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.visibility_outlined,
                        size: 44,
                        color: AppTheme.electricCyan,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Title & Description
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Text(
                  formatsText,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: AppTheme.electricCyan,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Vertical Action Pill Columns in Expanded Row (Camera, Gallery, Browse)
              Row(
                children: [
                  if (widget.category != MediaTypeCategory.audio) ...[
                    Expanded(
                      child: _buildActionPill(
                        onTap: () => _pickFromCamera(context),
                        icon: Icons.camera_alt_outlined,
                        label: 'Camera',
                        isPrimary: false,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionPill(
                        onTap: () => _pickFromGallery(context),
                        icon: Icons.photo_library_outlined,
                        label: 'Gallery',
                        isPrimary: false,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: _buildActionPill(
                      onTap: () => _pickFromFiles(context),
                      icon: Icons.folder_open_rounded,
                      label: 'Browse',
                      isPrimary: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionPill({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isPrimary
                ? const LinearGradient(
                    colors: [
                      AppTheme.electricCyan,
                      AppTheme.neonIndigo,
                    ],
                  )
                : LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.03),
                    ],
                  ),
            border: Border.all(
              color: isPrimary
                  ? Colors.transparent
                  : AppTheme.electricCyan.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppTheme.electricCyan.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isPrimary ? Colors.black : AppTheme.electricCyan,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? Colors.black : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
