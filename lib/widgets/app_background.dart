import 'package:flutter/material.dart';
import 'package:folio/core/app_colors.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      const Positioned.fill(child: ColoredBox(color: AppColors.bg)),
      _blob(const Alignment(-1, -1.1), AppColors.blobViolet),
      _blob(const Alignment(1.2, -0.3), AppColors.blobPink),
      _blob(const Alignment(-0.6, 1.2), AppColors.blobTeal),
      child,
    ]);
  }

  Widget _blob(Alignment at, Color color) => Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(center: at, radius: 0.9, colors: [color, Colors.transparent]),
          ),
        ),
      );
}