import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Colors - Soft Lavender Blue
  static const Color primaryBlue = Color(0xFF9BA4F5);
  static const Color primaryBlueLight = Color(0xFFB8C0FF);
  static const Color primaryBlueDark = Color(0xFF7D87E8);
  
  // Secondary Colors - Soft Mint/Teal
  static const Color secondaryTeal = Color(0xFF7FDCCC);
  static const Color secondaryTealLight = Color(0xFFA3EBE0);
  static const Color secondaryTealDark = Color(0xFF5FCDB9);
  
  // Accent Colors - Soft Coral/Peach
  static const Color accentCoral = Color(0xFFFFB4A9);
  static const Color accentCoralLight = Color(0xFFFFCFC7);
  static const Color accentCoralDark = Color(0xFFFF9B8C);
  
  // Accent Colors - Soft Lilac
  static const Color accentLilac = Color(0xFFD4BBFF);
  static const Color accentLilacLight = Color(0xFFE5D5FF);
  static const Color accentLilacDark = Color(0xFFC3A0FF);
  
  // Neutral Colors - Warmer tones
  static const Color white = Color(0xFFFFFBFE);
  static const Color black = Color(0xFF1C1B1F);
  static const Color grey50 = Color(0xFFFAF8FC);
  static const Color grey100 = Color(0xFFF3EFF5);
  static const Color grey200 = Color(0xFFEDE9EF);
  static const Color grey300 = Color(0xFFDDD8DF);
  static const Color grey400 = Color(0xFFC4BFC8);
  static const Color grey500 = Color(0xFFA8A3AC);
  static const Color grey600 = Color(0xFF8B8791);
  static const Color grey700 = Color(0xFF6F6B76);
  static const Color grey800 = Color(0xFF4A4650);
  static const Color grey900 = Color(0xFF2A2730);
  
  // Status Colors - Soft & Pastel
  static const Color success = Color(0xFF90E0AE);
  static const Color successLight = Color(0xFFB5EDCA);
  static const Color successDark = Color(0xFF6DD492);
  
  static const Color warning = Color(0xFFFFD89C);
  static const Color warningLight = Color(0xFFFFE5BC);
  static const Color warningDark = Color(0xFFFFCC7D);
  
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorLight = Color(0xFFFFCFC7);
  static const Color errorDark = Color(0xFFFF9B8C);
  
  static const Color info = Color(0xFF9DD9FF);
  static const Color infoLight = Color(0xFFBDE7FF);
  static const Color infoDark = Color(0xFF7DCCFF);
  
  // Password Strength Colors - Softer versions
  static const Color weak = Color(0xFFFFB4AB);
  static const Color medium = Color(0xFFFFD89C);
  static const Color strong = Color(0xFF90E0AE);
  static const Color veryStrong = Color(0xFF7FDCCC);
  
  // Category Colors - Pastel & Soft
  static const Color categoryPurple = Color(0xFFD4BBFF);
  static const Color categoryPink = Color(0xFFFFB4DB);
  static const Color categoryCoral = Color(0xFFFFB4A9);
  static const Color categoryPeach = Color(0xFFFFD4B8);
  static const Color categoryMint = Color(0xFFA3EBE0);
  static const Color categoryLavender = Color(0xFFB8C0FF);
  static const Color categorySky = Color(0xFF9DD9FF);
  
  // Dark Theme Colors - Softer dark palette
  static const Color darkBackground = Color(0xFF1A1820);
  static const Color darkSurface = Color(0xFF252230);
  static const Color darkCard = Color(0xFF2F2D38);
  static const Color darkDivider = Color(0xFF3D3A48);
}

class AppTextStyles {
  static TextStyle get _baseTextStyle => GoogleFonts.inter();
  
  // Headings
  static TextStyle get h1 => _baseTextStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
  
  static TextStyle get h2 => _baseTextStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
  
  static TextStyle get h3 => _baseTextStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  static TextStyle get h4 => _baseTextStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  static TextStyle get h5 => _baseTextStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  static TextStyle get h6 => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  // Body Text
  static TextStyle get bodyLarge => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  static TextStyle get bodyMedium => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  static TextStyle get bodySmall => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );
  
  // Labels & Captions
  static TextStyle get labelLarge => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  
  static TextStyle get labelMedium => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
  
  static TextStyle get labelSmall => _baseTextStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
  
  static TextStyle get caption => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.3,
    color: AppColors.grey600,
  );
  
  // Button Text
  static TextStyle get button => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  // Overline
  static TextStyle get overline => _baseTextStyle.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.6,
    letterSpacing: 1.5,
  );
}