import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// CyberMind AI visual identity:
/// deep space background, neon cyan/violet accents, terminal-green success,
/// alert-red danger — evoking a SOC (Security Operations Center) dashboard.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF05070D);
  static const Color surface = Color(0xFF0D111C);
  static const Color surfaceElevated = Color(0xFF141A2A);
  static const Color border = Color(0xFF232C42);

  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonViolet = Color(0xFF7C4DFF);
  static const Color neonPink = Color(0xFFFF3D9A);

  static const Color safe = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFC400);
  static const Color danger = Color(0xFFFF3B57);

  static const Color textPrimary = Color(0xFFE9EDF7);
  static const Color textSecondary = Color(0xFF8E97AE);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [neonViolet, neonCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color riskColor(int score) {
    if (score >= 70) return danger;
    if (score >= 40) return warning;
    return safe;
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    final colorScheme = const ColorScheme.dark().copyWith(
      primary: AppColors.neonCyan,
      secondary: AppColors.neonViolet,
      error: AppColors.danger,
      surface: AppColors.surface,
      background: AppColors.background,
      onPrimary: Colors.black,
      onSurface: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.4),
        ),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonCyan,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.neonCyan,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.neonCyan.withOpacity(0.18),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
