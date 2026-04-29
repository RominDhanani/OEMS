import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeType { light, dark, ocean, forest, sunset, midnight }

class AppTheme {
  // --- Standard Brand Colors ---
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color accentIndigo = Color(0xFF6366F1);

  // --- Design Tokens (Glassmorphism & Gradients) ---
  
  static BoxDecoration glassDecoration(BuildContext context, {double opacity = 0.05, double blur = 15.0}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: (isDark ? Colors.white : Colors.black).withOpacity(opacity),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
        width: 1.5,
      ),
    );
  }

  static LinearGradient premiumGradient(AppThemeType type) {
    switch (type) {
      case AppThemeType.ocean:
        return const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppThemeType.forest:
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppThemeType.sunset:
        return const LinearGradient(
          colors: [Color(0xFFF43F5E), Color(0xFFFB923C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppThemeType.midnight:
        return const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppThemeType.dark:
        return const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppThemeType.light:
        return const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  static ThemeData getTheme(AppThemeType type) {
    switch (type) {
      case AppThemeType.dark:
        return _darkTheme;
      case AppThemeType.ocean:
        return _oceanTheme;
      case AppThemeType.forest:
        return _forestTheme;
      case AppThemeType.sunset:
        return _sunsetTheme;
      case AppThemeType.midnight:
        return _midnightTheme;
      case AppThemeType.light:
        return _lightTheme;
    }
  }

  // --- Theme Definitions ---

  static ThemeData get _lightTheme {
    return _baseTheme(
      primaryColor: const Color(0xFF6366F1),
      backgroundColor: const Color(0xFFF3F4F6),
      surfaceColor: Colors.white,
      textColor: const Color(0xFF0F172A),
      isDark: false,
      accentColor: const Color(0xFF4F46E5),
    );
  }

  static ThemeData get _darkTheme {
    return _baseTheme(
      primaryColor: const Color(0xFF6366F1), // --primary-500
      backgroundColor: const Color(0xFF0B0F1A), // --bg-body
      surfaceColor: const Color(0xFF151C2E), // --bg-card
      textColor: const Color(0xFFF1F5F9), // --text-main
      isDark: true,
      accentColor: const Color(0xFF818CF8), // --primary-400
    );
  }

  static ThemeData get _oceanTheme {
    return _baseTheme(
      primaryColor: const Color(0xFF0EA5E9),
      backgroundColor: const Color(0xFFF0F9FF),
      surfaceColor: Colors.white,
      textColor: const Color(0xFF0C4A6E),
      isDark: false,
      accentColor: const Color(0xFF38BDF8),
    );
  }

  static ThemeData get _forestTheme {
    return _baseTheme(
      primaryColor: const Color(0xFF10B981), // --primary-500
      backgroundColor: const Color(0xFFF0FDF4), // --bg-body
      surfaceColor: Colors.white,
      textColor: const Color(0xFF064E3B), // --text-main
      isDark: false,
      accentColor: const Color(0xFF34D399), // --primary-400
    );
  }

  static ThemeData get _sunsetTheme {
    return _baseTheme(
      primaryColor: const Color(0xFFF97316), // --primary-500
      backgroundColor: const Color(0xFFFFF7ED), // --bg-body
      surfaceColor: Colors.white,
      textColor: const Color(0xFF431407), // --text-main
      isDark: false,
      accentColor: const Color(0xFFFB923C), // --primary-400
    );
  }

  static ThemeData get _midnightTheme {
    return _baseTheme(
      primaryColor: const Color(0xFF8B5CF6), // --primary-500
      backgroundColor: const Color(0xFF020617), // --bg-body
      surfaceColor: const Color(0xFF0F172A), // --bg-card
      textColor: const Color(0xFFF8FAFC), // --text-main
      isDark: true,
      accentColor: const Color(0xFFA78BFA), // --primary-400
    );
  }

  static ThemeData _baseTheme({
    required Color primaryColor,
    required Color backgroundColor,
    required Color surfaceColor,
    required Color textColor,
    required bool isDark,
    required Color accentColor,
  }) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceColor,
      onSurface: textColor,
      error: errorRed,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );

    // Modern Professional Radius
    const double baseRadius = 20.0;
    const double cardRadius = 24.0;

    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -1.5),
        displayMedium: GoogleFonts.outfit(fontSize: 30, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -1.0),
        displaySmall: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.5),
        headlineLarge: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.3),
        headlineMedium: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: textColor),
        headlineSmall: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
        titleLarge: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.2),
        titleMedium: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.1),
        titleSmall: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: textColor, height: 1.6),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textColor, height: 1.5),
        bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: textColor.withOpacity(isDark ? 0.75 : 0.6), height: 1.4),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: textColor, letterSpacing: 0.5),
        labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textColor.withOpacity(isDark ? 0.7 : 0.5), letterSpacing: 0.5),
      ),
      iconTheme: IconThemeData(
        color: textColor.withOpacity(isDark ? 0.95 : 0.85),
        size: 24,
      ),
      primaryIconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: isDark ? 2 : 0,
        shadowColor: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(
            color: isDark ? textColor.withOpacity(0.12) : const Color(0xFFE2E8F0), 
            width: 1.0,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? textColor.withOpacity(0.04) : textColor.withOpacity(0.04),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(baseRadius),
          borderSide: BorderSide(color: textColor.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(baseRadius),
          borderSide: BorderSide(color: textColor.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(baseRadius),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textColor.withOpacity(isDark ? 0.65 : 0.5)),
        floatingLabelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.w900),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(baseRadius)),
          elevation: 2,
          shadowColor: primaryColor.withOpacity(0.4),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith<double>((states) {
            if (states.contains(WidgetState.pressed)) return 0;
            return isDark ? 4 : 2;
          }),
          shadowColor: WidgetStateProperty.all(primaryColor.withOpacity(isDark ? 0.5 : 0.4)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(baseRadius)),
          side: BorderSide(color: primaryColor.withOpacity(0.5), width: 1.5),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryColor.withOpacity(isDark ? 0.15 : 0.1),
        labelStyle: TextStyle(color: isDark ? accentColor : primaryColor, fontWeight: FontWeight.w800, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: primaryColor.withOpacity(isDark ? 0.3 : 0.0), width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? textColor.withOpacity(0.12) : const Color(0xFFE2E8F0),
        thickness: 1,
        space: 24,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: isDark ? accentColor : primaryColor,
        unselectedLabelColor: textColor.withOpacity(isDark ? 0.65 : 0.45),
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        dividerColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: backgroundColor,
        indicatorColor: primaryColor.withOpacity(0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: primaryColor);
          }
          return GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textColor.withOpacity(0.5));
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(size: 24, color: primaryColor);
          }
          return IconThemeData(size: 24, color: textColor.withOpacity(0.5));
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: textColor),
        contentTextStyle: GoogleFonts.inter(fontSize: 15, color: textColor.withOpacity(0.8), height: 1.5),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
        contentTextStyle: GoogleFonts.inter(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 10,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        ),
        elevation: 20,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 6,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryColor;
          return isDark ? Colors.grey[700] : Colors.grey[400];
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryColor.withOpacity(0.4);
          return isDark ? Colors.grey[800] : Colors.grey[200];
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryColor;
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: BorderSide(color: textColor.withOpacity(0.2), width: 1.5),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryColor;
          return textColor.withOpacity(0.2);
        }),
      ),
    );
  }
}

