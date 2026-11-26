import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:folio/core/app_colors.dart';
import 'package:folio/widgets/primary_button.dart';

class _TopOutlineBorder extends ShapeBorder {
  const _TopOutlineBorder({
    this.radius = 24,
    this.color = AppColors.glassBorder,
  });

  final double radius;
  final Color color;

  static const _width = 1.0;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.only(top: _width);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
      ),
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect.deflate(_width), textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    // Sombra interna do Figma (x 0, y 1, blur 0, branco a 12%): faixa de 1 px
    // no topo, recortada pelo formato da folha.
    canvas.save();
    canvas.clipPath(getOuterPath(rect));
    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.top, rect.width, 1),
      Paint()..color = const Color(0x1FFFFFFF),
    );
    canvas.restore();

    // Traço centralizado em meio pixel para dentro: fica todo dentro da folha.
    final r = rect.deflate(_width / 2);
    final rad = Radius.circular(radius - _width / 2);
    final path = Path()
      ..moveTo(r.left, r.bottom)
      ..lineTo(r.left, r.top + rad.y)
      ..arcToPoint(Offset(r.left + rad.x, r.top), radius: rad)
      ..lineTo(r.right - rad.x, r.top)
      ..arcToPoint(Offset(r.right, r.top + rad.y), radius: rad)
      ..lineTo(r.right, r.bottom);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _width
        ..color = color,
    );
  }

  @override
  ShapeBorder scale(double t) =>
      _TopOutlineBorder(radius: radius * t, color: color);
}

class _GlassSheet extends StatelessWidget {
  const _GlassSheet({required this.child});
  final Widget child;

  static const _shape = _TopOutlineBorder();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: ClipPath(
            clipper: _OutsideShapeClipper(_shape),
            child: DecoratedBox(
              decoration: ShapeDecoration(
                shape: _shape,
                shadows: const [
                  BoxShadow(
                    color: Color(0x59000000),
                    offset: Offset(0, -10),
                    blurRadius: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
        ClipPath(
          clipper: const ShapeBorderClipper(shape: _shape),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: AppColors.glassBarTint,
                shape: _shape,
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

/// Recorta tudo que está DENTRO da folha, deixando só a sombra que vaza fora.
class _OutsideShapeClipper extends CustomClipper<Path> {
  const _OutsideShapeClipper(this.shape);
  final ShapeBorder shape;

  @override
  Path getClip(Size size) {
    final area = Path()
      ..addRect(Rect.fromLTRB(-80, -80, size.width + 80, size.height));
    return Path.combine(
      PathOperation.difference,
      area,
      shape.getOuterPath(Offset.zero & size),
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

void openDialogPermissionAccess(
  BuildContext context, {
  required Future<void> Function() onTap,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // permite altura maior que metade da tela
    useSafeArea: true,
    backgroundColor: Colors.transparent, // o vidro é desenhado por _GlassSheet
    elevation: 0,
    builder: (ctx) {
      return _GlassSheet(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            28,
            24,
            16 + MediaQuery.of(ctx).viewInsets.bottom, // sobe com o teclado
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // altura se ajusta ao conteúdo
            children: [
              Icon(Icons.lock_outline, size: 40, color: Color(0XFFBFC2FF)),
              SizedBox(height: 24),
              Text(
                'Por que precisamos dessa permissão?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: -0.44,
                  color: Color(0XFFE3E1E9),
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  text:
                      'Devido às restrições do sistema, o Android 11 e versões superiores exigem ',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0XFFC5C5D0),
                  ),
                  children: [
                    TextSpan(
                      text: '"Acesso a todos os arquivos" ',
                      style: TextStyle(
                        color: Color(0XFFBFC2FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: 'para listar as fotos e vídeos no seu dispositivo.',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14),
              Text.rich(
                TextSpan(
                  text:
                      '1. Esta permissão será usada somente para acessar fotos e vídeos no seu dispositivo e ',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0XFFC5C5D0),
                  ),
                  children: [
                    TextSpan(
                      text:
                          'não permitirá que tenhamos acesso aos seus dados privados, garantindo a segurança de dados no seu dispositivo.',
                      style: TextStyle(
                        color: Color(0XFFBFC2FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14),
              Text(
                '2. "Acesso a todos os arquivos" também é bastante considerado pelo Google. Qualquer app que solicite esta permissão precisa passar por um processo de avaliação rigoroso antes de ser disponibilizado no Google Play.',
                style: TextStyle(fontSize: 16, color: Color(0XFFC5C5D0)),
              ),
              SizedBox(height: 24),
              PrimaryButton(
                label: 'Vá agora',
                onPressed: () {
                  Navigator.of(ctx).pop(); // fecha a folha antes de ir
                  onTap();
                },
              ),
              SizedBox(height: 56),
            ],
          ),
        ),
      );
    },
  );
}
