import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  /// Soft shadow used by rounded white cards.
  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x14B45F1E), blurRadius: 14, offset: Offset(0, 4)),
  ];

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.orange,
      primary: AppColors.orange,
      surface: AppColors.cream,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
        titleLarge: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark),
        titleMedium: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textDark),
        bodySmall: TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
