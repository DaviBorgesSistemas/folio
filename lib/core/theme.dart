import 'package:flutter/material.dart';
import 'package:folio/core/app_colors.dart';
import 'package:folio/core/app_fonts.dart';

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
      fontFamily: AppFonts.family,
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
  );
}
