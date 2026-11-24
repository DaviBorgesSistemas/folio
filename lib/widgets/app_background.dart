import 'package:flutter/material.dart';
import 'package:folio/core/app_colors.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      const Positioned.fill(child: ColoredBox(color: AppColors.bg)),
      _blob(const Alignment(-1, -1.1), const Color(0x577A80FF)), // azul-violeta
      _blob(const Alignment(1.2, -0.3), const Color(0x33FF80BE)), // rosa
      _blob(const Alignment(-0.6, 1.2), const Color(0x333CC8D2)), // turquesa
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