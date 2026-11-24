import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF121318);
  static const surface = Color(0xFF1E1F25);
  static const surface2 = Color(0xFF292A31);
  static const line = Color(0xFF44454F);         
  static const text = Color(0xFFE3E1E9);
  static const muted = Color(0xFFC5C5D0);
  static const accent = Color(0xFFBFC2FF);       
  static const onAccent = Color(0xFF272A78);
  static const secContainer = Color(0xFF3F4165); 
  static const onSecContainer = Color(0xFFDFE0FF);
  static const danger = Color(0xFFFFB4AB);
}

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondaryContainer: AppColors.secContainer,
      onSecondaryContainer: AppColors.onSecContainer,
      outline: AppColors.line,
      surface: AppColors.surface,
      error: AppColors.danger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.text,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
  );
}
