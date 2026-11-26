import 'package:flutter/material.dart';
import 'package:folio/core/app_colors.dart';
import 'package:folio/core/app_fonts.dart';
import 'package:folio/core/app_images.dart';
import 'package:folio/core/context_ext.dart';

class SplashLogo extends StatefulWidget {
  const SplashLogo({super.key, this.onDone});

  /// Chamado quando a entrada (logo, nome e lema) termina.
  final VoidCallback? onDone;

  @override
  State<SplashLogo> createState() => _SplashLogoState();
}

class _SplashLogoState extends State<SplashLogo>
    with SingleTickerProviderStateMixin {
  static const _totalMs = 1200;
  static const _curve = Cubic(0.16, 1, 0.3, 1); 

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _totalMs),
  );

  late final Animation<double> _logo = _step(0, 900);
  late final Animation<double> _word = _step(250, 1000);
  late final Animation<double> _tagline = _step(450, 1200);

  /// Uma etapa da animação: começa em `startMs` e termina em `endMs`.
  Animation<double> _step(int startMs, int endMs) => CurvedAnimation(
        parent: _c,
        curve: Interval(startMs / _totalMs, endMs / _totalMs, curve: _curve),
      );

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(() {
      if (mounted) widget.onDone?.call();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: _logo,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.72, end: 1).animate(_logo),
            child: SizedBox(
              width: context.wp(35),
              child: AppSvg.asset(AppSvg.folioMark),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _FadeUp(
          animation: _word,
          distance: 12,
          child: const Text(
            'Folio',
            style: TextStyle(
              fontSize: 38,
              fontWeight: AppFonts.extraBold,
              height: 1,
              letterSpacing: -1.52,
              color: AppColors.text,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _FadeUp(
          animation: _tagline,
          distance: 10,
          child: const Text(
            'Sua galeria, organizada',
            style: TextStyle(
              fontSize: 15,
              fontWeight: AppFonts.regular,
              letterSpacing: -0.15,
              color: AppColors.muted,
            ),
          ),
        ),
      ],
    );
  }
}

class _FadeUp extends StatelessWidget {
  const _FadeUp({
    required this.animation,
    required this.distance,
    required this.child,
  });
  final Animation<double> animation;
  final double distance;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(0, distance * (1 - animation.value)),
          child: child,
        ),
      ),
    );
  }
}
