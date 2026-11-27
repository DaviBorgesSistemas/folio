
import 'package:flutter/material.dart';
import 'package:folio/core/app_colors.dart';

class BarAction extends StatelessWidget {
  const BarAction(this.icon, this.label, this.onTap, {super.key, this.color});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = onTap == null ? AppColors.muted.withAlpha(110) : (color ?? AppColors.text);
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: c),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: c)),
        ]),
      ),
    );
  }
}