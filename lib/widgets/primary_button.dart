import 'package:flutter/material.dart';
import 'package:folio/core/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  /// Botão preenchido com a cor `accent`.
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  }) : filled = true;

  /// Botão de fundo transparente, com texto e borda `accent`.
  const PrimaryButton.transparent({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  }) : filled = false;

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool filled;

  static const _onAccent = Color(0XFF4A4E83);

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? _onAccent : AppColors.accent;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: filled ? AppColors.accent : Colors.transparent,
          foregroundColor: foreground,
          disabledBackgroundColor:
              filled ? AppColors.accent.withValues(alpha: 0.55) : Colors.transparent,
          disabledForegroundColor: foreground.withValues(alpha: 0.55),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: icon != null
            ? Row(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(icon), Text(label)],
              )
            : Text(label),
      ),
    );
  }
}
