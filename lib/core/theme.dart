import 'package:flutter/material.dart';
import 'package:folio/core/app_colors.dart';
import 'package:folio/core/app_fonts.dart';
import 'package:folio/core/fade_route.dart';

ThemeData buildTheme() {
  // Com a fonte definida aqui, todo texto do app já usa a Plus Jakarta Sans.
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: AppFonts.family,
  );
  return base.copyWith(
    scaffoldBackgroundColor: Colors.transparent,
    pageTransitionsTheme: fadePageTransitions, // fade em toda troca de tela
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
