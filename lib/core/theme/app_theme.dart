import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand & High-Tech Color Tokens
  static const Color darkBackground = Color(0xFF080B10);
  static const Color darkBackgroundEnd = Color(0xFF0F141C);
  static const Color darkCardBackground = Color(0xFF131A26);
  static const Color darkSurfaceVariant = Color(0xFF161D2A);
  static const Color borderOverlay = Color(0x1AFFFFFF); // 10% white

  static const Color electricCyan = Color(0xFF00F2FE);
  static const Color cyanAccent = Color(0xFF00F2FE);
  static const Color neonIndigo = Color(0xFF6366F1);
  static const Color mintGreen = Color(0xFF10B981);
  static const Color emeraldSafe = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFFFB800);
  static const Color dangerRed = Color(0xFFFF2A6D);
  static const Color cyberPurple = Color(0xFFA855F7);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Background Ambient Gradient
  static const Gradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF080B10),
      Color(0xFF0D121B),
      Color(0xFF0F141C),
    ],
  );

  // Glass Pill Gradient
  static const Gradient glassPillGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x20FFFFFF),
      Color(0x0AFFFFFF),
    ],
  );

  // Cyan Indigo Neon Accent Gradient
  static const Gradient neonAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00F2FE),
      Color(0xFF6366F1),
    ],
  );

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: electricCyan,
        secondary: neonIndigo,
        tertiary: mintGreen,
        error: dangerRed,
        surface: darkSurfaceVariant,
        onSurface: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: darkCardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderOverlay, width: 0.8),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF080B10).withValues(alpha: 0.95),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 0.4,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0B0F17),
        selectedItemColor: electricCyan,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(color: textPrimary, fontWeight: FontWeight.w800),
        titleLarge: GoogleFonts.plusJakartaSans(color: textPrimary, fontWeight: FontWeight.w700),
        titleMedium: GoogleFonts.plusJakartaSans(color: textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: textPrimary),
        bodyMedium: GoogleFonts.inter(color: textSecondary),
        labelLarge: GoogleFonts.jetBrainsMono(color: electricCyan, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Color helper for risk levels
  static Color getRiskColor(double score) {
    if (score < 0.35) return mintGreen;
    if (score < 0.70) return warningAmber;
    return dangerRed;
  }
}

/// Reusable High-Performance Static Glass Container Widget
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 24,
    this.color,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? const Color(0xFF131A26).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(color: AppTheme.borderOverlay, width: 0.8),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
      ),
      child: child,
    );
  }
}
