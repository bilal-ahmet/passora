import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {


  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        // Primary colors
        primary: Color(0xFF1976D2),
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFE3F2FD),
        onPrimaryContainer: Color(0xFF0D47A1),
        
        // Secondary colors
        secondary: Color(0xFF3F51B5),
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFE8EAF6),
        onSecondaryContainer: Color(0xFF1A237E),
        
        // Surface colors
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF1C1B1F),
        surfaceVariant: Color(0xFFF3F2F7),
        onSurfaceVariant: Color(0xFF46464F),
        surfaceContainer: Color(0xFFF9F9FF),
        
        // Outline colors
        outline: Color(0xFF767680),
        outlineVariant: Color(0xFFC7C5D0),
        
        // Error colors
        error: Color(0xFFBA1A1A),
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),
        
        // Background
        background: Color(0xFFFEFBFF),
        onBackground: Color(0xFF1C1B1F),
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFEFBFF),
        foregroundColor: const Color(0xFF1C1B1F),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h5.copyWith(
          color: const Color(0xFF1C1B1F),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(
          color: Color(0xFF46464F),
          size: 24,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: const Color(0xFFF9F9FF),
        shadowColor: const Color(0xFF767680).withValues(alpha: 0.15),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: const Color(0xFFFFFFFF),
          elevation: 1,
          shadowColor: const Color(0xFF1976D2).withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          textStyle: AppTextStyles.button,
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF1976D2),
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F2F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF767680)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF767680)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 2),
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: const Color(0xFF46464F),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: const Color(0xFF767680),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: Color(0xFF46464F),
        size: 24,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFFC7C5D0),
        thickness: 1,
        space: 1,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFFEFBFF),
        selectedItemColor: Color(0xFF1976D2),
        unselectedItemColor: Color(0xFF767680),
        type: BottomNavigationBarType.fixed,
        elevation: 3,
      ),
      
      // FloatingActionButton Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF1976D2),
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 6,
        shape: CircleBorder(),
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: const Color(0xFFFEFBFF),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(color: const Color(0xFF1C1B1F)),
        displayMedium: AppTextStyles.h2.copyWith(color: const Color(0xFF1C1B1F)),
        displaySmall: AppTextStyles.h3.copyWith(color: const Color(0xFF1C1B1F)),
        headlineLarge: AppTextStyles.h4.copyWith(color: const Color(0xFF1C1B1F)),
        headlineMedium: AppTextStyles.h5.copyWith(color: const Color(0xFF1C1B1F)),
        headlineSmall: AppTextStyles.h6.copyWith(color: const Color(0xFF1C1B1F)),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: const Color(0xFF1C1B1F)),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF46464F)),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF46464F)),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: const Color(0xFF46464F)),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: const Color(0xFF46464F)),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF767680)),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        // Primary colors (Blue-based for trust/security)
        primary: Color(0xFF82B1FF),
        onPrimary: Color(0xFF003D82),
        primaryContainer: Color(0xFF1565C0),
        onPrimaryContainer: Color(0xFFE3F2FD),
        
        // Secondary colors (Indigo accent)
        secondary: Color(0xFF8C9EFF),
        onSecondary: Color(0xFF000051),
        secondaryContainer: Color(0xFF3F51B5),
        onSecondaryContainer: Color(0xFFE8EAF6),
        
        // Surface colors
        surface: Color(0xFF121212),
        onSurface: Color(0xFFE3E3E3),
        surfaceVariant: Color(0xFF1E1E1E),
        onSurfaceVariant: Color(0xFFB8B8B8),
        surfaceContainer: Color(0xFF2A2A2A),
        
        // Outline colors
        outline: Color(0xFF3F3F3F),
        outlineVariant: Color(0xFF2F2F2F),
        
        // Error colors
        error: Color(0xFFFF6B6B),
        onError: Color(0xFF680003),
        errorContainer: Color(0xFF8B0000),
        onErrorContainer: Color(0xFFFFEDEA),
        
        // Background
        background: Color(0xFF0F0F0F),
        onBackground: Color(0xFFE0E0E0),
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: const Color(0xFFE3E3E3),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h5.copyWith(
          color: const Color(0xFFE3E3E3),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(
          color: Color(0xFFB8B8B8),
          size: 24,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: const Color(0xFF2A2A2A),
        shadowColor: const Color(0xFF000000).withValues(alpha: 0.3),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF82B1FF),
          foregroundColor: const Color(0xFF003D82),
          elevation: 1,
          shadowColor: const Color(0xFF82B1FF).withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          textStyle: AppTextStyles.button,
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF82B1FF),
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF3F3F3F)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF3F3F3F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF82B1FF), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF2F2F2F)),
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: const Color(0xFFB8B8B8),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: const Color(0xFF3F3F3F),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: Color(0xFFB8B8B8),
        size: 24,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2F2F2F),
        thickness: 1,
        space: 1,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF121212),
        selectedItemColor: Color(0xFF82B1FF),
        unselectedItemColor: Color(0xFF3F3F3F),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // FloatingActionButton Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF82B1FF),
        foregroundColor: Color(0xFF003D82),
        elevation: 6,
        shape: CircleBorder(),
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: const Color(0xFF0F0F0F),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(color: const Color(0xFFE3E3E3)),
        displayMedium: AppTextStyles.h2.copyWith(color: const Color(0xFFE3E3E3)),
        displaySmall: AppTextStyles.h3.copyWith(color: const Color(0xFFE3E3E3)),
        headlineLarge: AppTextStyles.h4.copyWith(color: const Color(0xFFE3E3E3)),
        headlineMedium: AppTextStyles.h5.copyWith(color: const Color(0xFFE3E3E3)),
        headlineSmall: AppTextStyles.h6.copyWith(color: const Color(0xFFE3E3E3)),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: const Color(0xFFE3E3E3)),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFFB8B8B8)),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: const Color(0xFFB8B8B8)),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: const Color(0xFFB8B8B8)),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: const Color(0xFFB8B8B8)),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF3F3F3F)),
      ),
    );
  }
}