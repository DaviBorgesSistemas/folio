import 'package:flutter/material.dart';
import 'package:folio/core/app_colors.dart';

/// Fundo do app: base escura com três manchas elípticas e suaves,
/// igual ao `radial-gradient` do protótipo (folio.html).
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      const Positioned.fill(
        child: RepaintBoundary(child: CustomPaint(painter: _GlowPainter())),
      ),
      child,
    ]);
  }
}

class _Glow {
  const _Glow(this.x, this.y, this.rx, this.ry, this.color);
  final double x, y; // centro, em fração da tela
  final double rx, ry; // raios, em fração da largura e da altura
  final Color color;
}

class _GlowPainter extends CustomPainter {
  const _GlowPainter();

  // Mesmos valores do CSS: elipse "rx ry at x y", transparente aos 70%.
  static const _glows = [
    _Glow(0.08, 0.00, 0.70, 0.38, AppColors.blobViolet),
    _Glow(1.00, 0.28, 0.55, 0.34, AppColors.blobPink),
    _Glow(0.20, 1.00, 0.70, 0.40, AppColors.blobTeal),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = AppColors.bg);

    for (final g in _glows) {
      final center = Offset(size.width * g.x, size.height * g.y);
      // Gradiente circular de raio 1, esticado para virar elipse.
      final m = Matrix4.identity()
        ..translateByDouble(center.dx, center.dy, 0, 1)
        ..scaleByDouble(size.width * g.rx, size.height * g.ry, 1, 1);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(
            radius: 1,
            colors: [g.color, g.color.withValues(alpha: 0)],
            stops: const [0, 0.7],
            transform: _MatrixTransform(m),
          ).createShader(Rect.fromCircle(center: Offset.zero, radius: 1)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MatrixTransform extends GradientTransform {
  const _MatrixTransform(this.matrix);
  final Matrix4 matrix;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) => matrix;
}
