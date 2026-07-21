import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/media_validators.dart';

class MediaTypeSelector extends StatelessWidget {
  final MediaTypeCategory selectedCategory;
  final ValueChanged<MediaTypeCategory> onCategoryChanged;

  const MediaTypeSelector({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  Alignment _getAlignment() {
    switch (selectedCategory) {
      case MediaTypeCategory.image:
        return Alignment.centerLeft;
      case MediaTypeCategory.video:
        return Alignment.center;
      case MediaTypeCategory.audio:
        return Alignment.centerRight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = MediaTypeCategory.values;

    return Container(
      height: 54,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF161D2A).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated Sliding Neon Pill Indicator
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            alignment: _getAlignment(),
            child: FractionallySizedBox(
              widthFactor: 1 / categories.length,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.electricCyan,
                      AppTheme.neonIndigo,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.electricCyan.withValues(alpha: 0.4),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Selector Buttons Row
          Row(
            children: categories.map((category) {
              final isSelected = selectedCategory == category;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onCategoryChanged(category),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.black : AppTheme.textSecondary,
                        letterSpacing: 0.6,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              category == MediaTypeCategory.image
                                  ? Icons.image_outlined
                                  : category == MediaTypeCategory.video
                                      ? Icons.videocam_outlined
                                      : Icons.graphic_eq_rounded,
                              key: ValueKey('${category.name}_$isSelected'),
                              size: 18,
                              color: isSelected ? Colors.black : AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(category.name.toUpperCase()),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
