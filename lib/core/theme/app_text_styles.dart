import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelime_kralligi/core/theme/app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle get displayTitle => GoogleFonts.fredoka(
    fontSize: 42,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.05,
    shadows: [
      Shadow(
        color: Colors.black.withValues(alpha: 0.24),
        offset: const Offset(0, 4),
        blurRadius: 8,
      ),
    ],
  );

  static TextStyle get screenTitle => GoogleFonts.fredoka(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle get sectionTitle => GoogleFonts.fredoka(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.navy,
  );

  static TextStyle get cardTitle => GoogleFonts.fredoka(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.navy,
  );

  static TextStyle get bodyLarge => GoogleFonts.fredoka(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.navy,
    height: 1.4,
  );

  static TextStyle get bodyMedium => GoogleFonts.fredoka(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF60708A),
    height: 1.35,
  );

  static TextStyle get buttonLarge => GoogleFonts.fredoka(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  static TextStyle get label => GoogleFonts.fredoka(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.7,
    color: const Color(0xFF718096),
  );

  static TextStyle get mascotSpeech => GoogleFonts.fredoka(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    color: AppColors.navy,
    height: 1.4,
  );

  static TextStyle get score => GoogleFonts.fredoka(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  const AppTextStyles._();
}
