import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:folio/core/app_colors.dart';

class GlassBox extends StatelessWidget {
  const GlassBox({
    super.key,
    required this.child,
    this.radius = 28,
    this.padding = EdgeInsets.zero,
    this.tint = AppColors.glassTint,
    this.blur = 22, // sigma do Flutter: o "blur" do Figma dividido por 2
    this.innerHighlight = false,
  });
  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final Color tint;
  final double blur;

  /// Em vez da borda em volta, desenha só um brilho fino no topo, como a
  /// "inner shadow" do Figma (x 0, y 1, blur 0, branco a 14%).
  final bool innerHighlight;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: CustomPaint(
          foregroundPainter:
              innerHighlight ? _InnerHighlightPainter(radius) : null,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(radius),
              border: innerHighlight
                  ? null
                  : Border.all(color: AppColors.glassBorder),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Inner shadow com y = 1 e blur = 0: a faixa de 1 px que sobra quando se
/// tira da forma a própria forma deslocada 1 px para baixo. Acompanha os cantos.
class _InnerHighlightPainter extends CustomPainter {
  _InnerHighlightPainter(this.radius);
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final shape = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Offset.zero & size, Radius.circular(radius)));
    final band = Path.combine(
        PathOperation.difference, shape, shape.shift(const Offset(0, 1)));
    canvas.drawPath(band, Paint()..color = AppColors.glassBorder);
  }

  @override
  bool shouldRepaint(_InnerHighlightPainter old) => old.radius != radius;
}

/// Barra flutuante com vidro, usada no visualizador (ações) e na pasta (seleção).
class GlassBar extends StatelessWidget {
  const GlassBar({super.key, required this.child, this.height = 68});
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: SizedBox(
        height: height,
        child: GlassBox(
          radius: 28,
          tint: AppColors.glassBarTint,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: child,
        ),
      ),
    );
  }
}