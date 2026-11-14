import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  // Only dark theme - glassmorphism design
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        // Primary colors - Soft lavender in dark mode
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
        
        // Surface colors - New gradient base colors
        surface: Color(0xFF0D0B1F),
        onSurface: Color(0xFFE6E1E9),
        surfaceContainerHighest: Color(0xFF1A1547),
        onSurfaceVariant: Color(0xFFC4BFC8),
        surfaceContainer: Color(0xFF2D1B4E),
        
        // Outline colors
        outline: Color(0xFF3D3A48),
        outlineVariant: Color(0xFF2D1B4E),
        
        // Error colors - Softer
        error: Color(0xFFFFCFC7),
        onError: Color(0xFF3A1A1A),
        errorContainer: Color(0xFFFF6B5E),
        onErrorContainer: Color(0xFFFFE8E4),
      ),
      
      // AppBar Theme - Transparent for gradient background
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFE6E1E9),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h5.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),
      
      // Card Theme - Glassmorphism style
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.1),
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
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
          elevation: 0,
          shadowColor: Colors.transparent,
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
      
      // Input Decoration Theme - Glassmorphism style
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
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
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: Colors.white.withValues(alpha: 0.7),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white.withValues(alpha: 0.5),
        ),
        prefixIconColor: Colors.white.withValues(alpha: 0.7),
        suffixIconColor: Colors.white.withValues(alpha: 0.7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      
      // Icon Theme
      iconTheme: IconThemeData(
        color: Colors.white.withValues(alpha: 0.7),
        size: 24,
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.1),
        thickness: 1,
        space: 1,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFFB8C0FF),
        unselectedItemColor: Colors.white.withValues(alpha: 0.5),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      
      // FloatingActionButton Theme - Will be overridden with gradient
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFB8C0FF),
        foregroundColor: Color(0xFF1A1B3A),
        elevation: 0,
        shape: StadiumBorder(),
      ),
      
      // Scaffold Background - Transparent for gradient
      scaffoldBackgroundColor: Colors.transparent,
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1A1547),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        titleTextStyle: AppTextStyles.h5.copyWith(color: Colors.white),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: const Color(0xFF1A1547),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        modalBarrierColor: Colors.black.withValues(alpha: 0.5),
      ),
      
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2D1B4E),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Popup Menu Theme
      popupMenuTheme: PopupMenuThemeData(
        color: const Color(0xFF1A1547),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        textStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFB8C0FF);
          }
          return Colors.white.withValues(alpha: 0.5);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFB8C0FF).withValues(alpha: 0.3);
          }
          return Colors.white.withValues(alpha: 0.1);
        }),
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFB8C0FF);
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(const Color(0xFF1A1B3A)),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(color: Colors.white),
        displayMedium: AppTextStyles.h2.copyWith(color: Colors.white),
        displaySmall: AppTextStyles.h3.copyWith(color: Colors.white),
        headlineLarge: AppTextStyles.h4.copyWith(color: Colors.white),
        headlineMedium: AppTextStyles.h5.copyWith(color: Colors.white),
        headlineSmall: AppTextStyles.h6.copyWith(color: Colors.white),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.7)),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.7)),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: Colors.white.withValues(alpha: 0.7)),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: Colors.white.withValues(alpha: 0.7)),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.5)),
      ),
    );
  }
  
  // Keep lightTheme as alias to darkTheme for backward compatibility
  static ThemeData get lightTheme => darkTheme;
}