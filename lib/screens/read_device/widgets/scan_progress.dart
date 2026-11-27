import 'package:flutter/material.dart';
import 'package:folio/core/app_colors.dart';
import 'package:folio/screens/read_device/scan_models.dart';

/// Barra de progresso com o texto de porcentagem logo abaixo.
class ScanProgress extends StatelessWidget {
  const ScanProgress({super.key, required this.state});

  final ScanState state;

  // EXPLICA: cor do "trilho" (a parte escura que fica atrás do preenchimento).
  static const _trackColor = Color(0XFF27272D);

  String get _label =>
      state.isPreparing ? 'Procurando pastas…' : '${state.percent}% concluído';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Bar(progress: state.progress),
        const SizedBox(height: 8),
        Text(_label, style: const TextStyle(color: AppColors.muted)),
      ],
    );
  }
}

// EXPLICA: classe com "_" no início é privada deste arquivo. Ninguém fora
// daqui consegue usar a _Bar; é um detalhe interno do ScanProgress.
class _Bar extends StatelessWidget {
  const _Bar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    // EXPLICA: a barra são dois retângulos arredondados, um dentro do outro:
    // o de fora é o trilho (cor escura) e o de dentro é o preenchimento
    // (cor accent), com uma fração da largura do trilho.
    return Container(
      height: 8,
      // EXPLICA: clipBehavior recorta o filho nas bordas arredondadas do pai.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: ScanProgress._trackColor,
        borderRadius: BorderRadius.circular(16),
      ),
      // EXPLICA: sem o Align, o trilho forçaria o filho a ocupar toda a
      // largura e o widthFactor seria ignorado. O Align deixa o preenchimento
      // com o tamanho que ele pedir, encostado na esquerda.
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          // EXPLICA: widthFactor é a FRAÇÃO da largura do pai (0.0 a 1.0).
          // O clamp garante que nunca saia desse intervalo.
          widthFactor: progress.clamp(0.0, 1.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
