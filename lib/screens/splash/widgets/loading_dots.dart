import 'package:flutter/material.dart';
import 'package:folio/core/app_colors.dart';

/// Três pontos que pulsam em sequência, como no protótipo (dotPulse):
/// 1,8 s por ciclo, com 0,35 s de atraso entre um ponto e o próximo.
class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  static const _cycle = Duration(milliseconds: 1800);
  // Atraso de cada ponto como fração do ciclo (0 s, 0,35 s e 0,7 s de 1,8 s).
  static const _delays = [0.0, 0.35 / 1.8, 0.7 / 1.8];

  late final AnimationController _loop =
      AnimationController(vsync: this, duration: _cycle)..repeat();

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _loop,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final delay in _delays) _dot(_pulse(delay)),
          ],
        );
      },
    );
  }

  /// 0 = ponto apagado, 1 = ponto aceso. Sobe até a metade do ciclo e desce.
  double _pulse(double delay) {
    final t = ((_loop.value - delay) % 1.0 + 1.0) % 1.0;
    final half = t < 0.5 ? t * 2 : (1 - t) * 2;
    return Curves.easeInOut.transform(half);
  }

  Widget _dot(double pulse) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4), // 8 px entre pontos
      child: Transform.scale(
        scale: 1 + 0.18 * pulse,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.lerp(AppColors.dotIdle, AppColors.accent, pulse),
            boxShadow: pulse == 0
                ? null
                : [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.6 * pulse),
                      blurRadius: 8,
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
