import 'package:flutter/material.dart';
import 'package:folio/core/app_colors.dart';
import 'package:folio/core/format.dart';
import 'package:folio/screens/read_device/scan_models.dart';

// EXPLICA: StatelessWidget = widget sem estado próprio. Ele só desenha o que
// recebe pelo construtor (aqui, o ScanState). Quando o estado muda, o pai
// cria um novo ScanHeader com o novo valor.
/// Título, total de imagens e quantas pastas já foram encontradas.
class ScanHeader extends StatelessWidget {
  const ScanHeader({super.key, required this.state});

  final ScanState state;

  // EXPLICA: a regra do texto fica num getter, fora do build, para o build
  // continuar fácil de ler. Durante o "preparando" não há pastas ainda, então
  // não faz sentido dizer "em 0 pastas".
  String get _subtitle {
    if (state.isPreparing) return 'imagens encontradas';
    final n = state.folderCount;
    return 'imagens encontradas em $n ${n == 1 ? 'pasta' : 'pastas'}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lendo seu celular',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
            // EXPLICA: `height: 1` tira a folga que a fonte reserva em cima
            // e embaixo do texto. Sem isso aparece um espaço "invisível".
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          // EXPLICA: fmt vem de core/format.dart: 10917 -> "10.917".
          fmt(state.found),
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
            height: 1,
            // EXPLICA: dígitos de largura fixa. Sem isso o número "dança"
            // para os lados enquanto sobe, porque o "1" é mais estreito que
            // o "8".
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _subtitle,
          style: const TextStyle(fontSize: 16, color: AppColors.muted),
        ),
      ],
    );
  }
}
