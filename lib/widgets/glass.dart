import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:folio/core/theme.dart';

class GlassBox extends StatelessWidget {
  const GlassBox({
    super.key,
    required this.child,
    this.radius = 28,
    this.padding = EdgeInsets.zero,
    this.tint = const Color(0x12FFFFFF), // branco a ~7%
    this.blur = 22,
  });
  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final Color tint;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: const Color(0x24FFFFFF)), // borda clara e fina
          ),
          child: child,
        ),
      ),
    );
  }
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
          tint: const Color(0x9E22232C), // mais escuro: precisa ler bem sobre fotos
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: child,
        ),
      ),
    );
  }
}