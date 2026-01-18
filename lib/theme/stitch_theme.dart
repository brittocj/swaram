import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StitchColors {
  // Brand
  static const Color primary = Color(0xFF00FF9D);
  static const Color g9Blue = Color(0xFF007BFF);
  
  // Backgrounds
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F1115);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1A1D24);
  
  // Text
  static const Color textLight = Color(0xFF111827);
  static const Color textDark = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF64748B);
  
  // Semantic
  static const Color silent = Color(0xFF4ADE80);
  static const Color moderate = Color(0xFFFACC15);
  static const Color noisy = Color(0xFFFB923C);
  static const Color danger = Color(0xFFEF4444);
  static const Color damage = Color(0xFFBE123C);
}

class StitchTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: StitchColors.backgroundDark,
      cardColor: StitchColors.cardDark,
      colorScheme: const ColorScheme.dark(
        primary: StitchColors.primary,
        surface: StitchColors.cardDark,
        onSurface: StitchColors.textDark,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          color: StitchColors.textDark,
          fontSize: 72,
          fontWeight: FontWeight.w200,
          letterSpacing: -4,
        ),
        displayMedium: GoogleFonts.inter(
          color: StitchColors.textDark,
          fontSize: 28,
          fontWeight: FontWeight.w300,
          letterSpacing: -1,
        ),
        titleMedium: GoogleFonts.inter(
          color: StitchColors.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
        bodyMedium: GoogleFonts.inter(
          color: StitchColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelSmall: GoogleFonts.inter(
          color: StitchColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
