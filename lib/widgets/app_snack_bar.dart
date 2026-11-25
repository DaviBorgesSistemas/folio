import 'package:flutter/material.dart';
import 'package:folio/core/app_colors.dart';

enum AppSnackBarType { info, success, error }

/// Padrão de aviso rápido do app. Use `AppSnackBar.show(context, ...)` em vez
/// de montar um `SnackBar` na mão.
class AppSnackBar {
  static void show(
    BuildContext context,
    String message, {
    AppSnackBarType type = AppSnackBarType.info,
  }) {
    final (icon, color) = switch (type) {
      AppSnackBarType.info => (Icons.info_outline_rounded, AppColors.accent),
      AppSnackBarType.success => (Icons.check_circle_outline_rounded, AppColors.accent),
      AppSnackBarType.error => (Icons.error_outline_rounded, AppColors.danger),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surface2,
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.glassBorder),
          ),
          content: Row(
            spacing: 12,
            children: [
              Icon(icon, size: 22, color: color),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
