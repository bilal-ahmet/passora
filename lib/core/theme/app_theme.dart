import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {


  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        // Primary colors - Soft Lavender Blue
        primary: Color(0xFF9BA4F5),
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFE5E8FF),
        onPrimaryContainer: Color(0xFF4A54C8),
        
        // Secondary colors - Soft Mint
        secondary: Color(0xFF7FDCCC),
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFE0F7F4),
        onSecondaryContainer: Color(0xFF3FBAAA),
        
        // Tertiary - Soft Coral
        tertiary: Color(0xFFFFB4A9),
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFFFFE8E4),
        onTertiaryContainer: Color(0xFFFF8A7B),
        
        // Surface colors - Warmer neutrals
        surface: Color(0xFFFFFBFE),
        onSurface: Color(0xFF1C1B1F),
        surfaceVariant: Color(0xFFF3EFF5),
        onSurfaceVariant: Color(0xFF6F6B76),
        surfaceContainer: Color(0xFFFAF8FC),
        
        // Outline colors
        outline: Color(0xFFDDD8DF),
        outlineVariant: Color(0xFFEDE9EF),
        
        // Error colors - Softer
        error: Color(0xFFFFB4AB),
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFFFFE8E4),
        onErrorContainer: Color(0xFFFF6B5E),
        
        // Background
        background: Color(0xFFFFFBFE),
        onBackground: Color(0xFF1C1B1F),
      ),
      
      // AppBar Theme - Soft gradient background
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFFFBFE),
        foregroundColor: const Color(0xFF1C1B1F),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h5.copyWith(
          color: const Color(0xFF1C1B1F),
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(
          color: Color(0xFF6F6B76),
          size: 24,
        ),
      ),
      
      // Card Theme - More rounded, softer shadows
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFBFE),
        shadowColor: const Color(0xFF9BA4F5).withValues(alpha: 0.08),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: const Color(0xFFEDE9EF).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Elevated Button Theme - Soft pastel
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9BA4F5),
          foregroundColor: const Color(0xFFFFFFFF),
          elevation: 2,
          shadowColor: const Color(0xFF9BA4F5).withValues(alpha: 0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          textStyle: AppTextStyles.button.copyWith(
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF9BA4F5),
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Input Decoration Theme - Soft rounded fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3EFF5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFEDE9EF),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF9BA4F5),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFFFB4AB),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFFFB4AB),
            width: 2,
          ),
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: const Color(0xFF6F6B76),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: const Color(0xFFA8A3AC),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: Color(0xFF6F6B76),
        size: 24,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEDE9EF),
        thickness: 1,
        space: 1,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFFFFBFE),
        selectedItemColor: Color(0xFF9BA4F5),
        unselectedItemColor: Color(0xFFC4BFC8),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // FloatingActionButton Theme - Soft gradient
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF9BA4F5),
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 4,
        shape: CircleBorder(),
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: const Color(0xFFFFFBFE),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(color: const Color(0xFF1C1B1F)),
        displayMedium: AppTextStyles.h2.copyWith(color: const Color(0xFF1C1B1F)),
        displaySmall: AppTextStyles.h3.copyWith(color: const Color(0xFF1C1B1F)),
        headlineLarge: AppTextStyles.h4.copyWith(color: const Color(0xFF1C1B1F)),
        headlineMedium: AppTextStyles.h5.copyWith(color: const Color(0xFF1C1B1F)),
        headlineSmall: AppTextStyles.h6.copyWith(color: const Color(0xFF1C1B1F)),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: const Color(0xFF1C1B1F)),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF6F6B76)),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF6F6B76)),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: const Color(0xFF6F6B76)),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: const Color(0xFF6F6B76)),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: const Color(0xFFA8A3AC)),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        // Primary colors - Softer lavender in dark mode
        primary: Color(0xFFB8C0FF),
        onPrimary: Color(0xFF1A1B3A),
        primaryContainer: Color(0xFF4A54C8),
        onPrimaryContainer: Color(0xFFE5E8FF),
        
        // Secondary colors - Soft mint in dark
        secondary: Color(0xFFA3EBE0),
        onSecondary: Color(0xFF1A3A36),
        secondaryContainer: Color(0xFF3FBAAA),
        onSecondaryContainer: Color(0xFFE0F7F4),
        
        // Tertiary - Soft coral in dark
        tertiary: Color(0xFFFFCFC7),
        onTertiary: Color(0xFF3A1A1A),
        tertiaryContainer: Color(0xFFFF8A7B),
        onTertiaryContainer: Color(0xFFFFE8E4),
        
        // Surface colors - Warmer dark tones
        surface: Color(0xFF1A1820),
        onSurface: Color(0xFFE6E1E9),
        surfaceVariant: Color(0xFF252230),
        onSurfaceVariant: Color(0xFFC4BFC8),
        surfaceContainer: Color(0xFF2F2D38),
        
        // Outline colors
        outline: Color(0xFF3D3A48),
        outlineVariant: Color(0xFF2F2D38),
        
        // Error colors - Softer
        error: Color(0xFFFFCFC7),
        onError: Color(0xFF3A1A1A),
        errorContainer: Color(0xFFFF6B5E),
        onErrorContainer: Color(0xFFFFE8E4),
        
        // Background
        background: Color(0xFF1A1820),
        onBackground: Color(0xFFE6E1E9),
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1A1820),
        foregroundColor: const Color(0xFFE6E1E9),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h5.copyWith(
          color: const Color(0xFFE6E1E9),
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(
          color: Color(0xFFC4BFC8),
          size: 24,
        ),
      ),
      
      // Card Theme - Softer shadows
      cardTheme: CardThemeData(
        color: const Color(0xFF252230),
        shadowColor: const Color(0xFF9BA4F5).withValues(alpha: 0.06),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: const Color(0xFF3D3A48).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB8C0FF),
          foregroundColor: const Color(0xFF1A1B3A),
          elevation: 2,
          shadowColor: const Color(0xFFB8C0FF).withValues(alpha: 0.20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          textStyle: AppTextStyles.button.copyWith(
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFB8C0FF),
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF252230),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF3D3A48),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFB8C0FF),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFFFCFC7),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFFFCFC7),
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF2F2D38),
            width: 1,
          ),
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: const Color(0xFFC4BFC8),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: const Color(0xFF6F6B76),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: Color(0xFFC4BFC8),
        size: 24,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3D3A48),
        thickness: 1,
        space: 1,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A1820),
        selectedItemColor: Color(0xFFB8C0FF),
        unselectedItemColor: Color(0xFF6F6B76),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // FloatingActionButton Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFB8C0FF),
        foregroundColor: Color(0xFF1A1B3A),
        elevation: 4,
        shape: CircleBorder(),
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: const Color(0xFF1A1820),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(color: const Color(0xFFE6E1E9)),
        displayMedium: AppTextStyles.h2.copyWith(color: const Color(0xFFE6E1E9)),
        displaySmall: AppTextStyles.h3.copyWith(color: const Color(0xFFE6E1E9)),
        headlineLarge: AppTextStyles.h4.copyWith(color: const Color(0xFFE6E1E9)),
        headlineMedium: AppTextStyles.h5.copyWith(color: const Color(0xFFE6E1E9)),
        headlineSmall: AppTextStyles.h6.copyWith(color: const Color(0xFFE6E1E9)),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: const Color(0xFFE6E1E9)),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFFC4BFC8)),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: const Color(0xFFC4BFC8)),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: const Color(0xFFC4BFC8)),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: const Color(0xFFC4BFC8)),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF8B8791)),
      ),
    );
  }
}