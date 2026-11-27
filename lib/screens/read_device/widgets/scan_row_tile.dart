import 'package:flutter/material.dart';
import 'package:folio/core/app_colors.dart';
import 'package:folio/core/format.dart';
import 'package:folio/screens/read_device/scan_models.dart';

/// Uma pasta na lista: ícone (✓ ou carregando), nome e quantidade de imagens.
class ScanRowTile extends StatelessWidget {
  const ScanRowTile({super.key, required this.row});

  final ScanRow row;

  // EXPLICA: pasta em andamento mostra "…" depois do número, para indicar que
  // a contagem ainda está subindo.
  String get _countLabel =>
      row.isDone ? fmt(row.count) : '${fmt(row.count)}…';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        // EXPLICA: `spacing` coloca 12px entre cada filho da Row, sem
        // precisar de SizedBox(width: 12) entre eles.
        spacing: 12,
        children: [
          _StatusIcon(isDone: row.isDone),
          // EXPLICA: Expanded faz o nome ocupar todo o espaço que sobra,
          // empurrando a contagem para o canto direito. Sem ele, nomes longos
          // estourariam a linha; com o ellipsis eles viram "Nome lon…".
          Expanded(
            child: Text(
              row.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
          Text(
            _countLabel,
            style: TextStyle(
              fontSize: 15,
              // EXPLICA: concluída = cor apagada; em andamento = cor de
              // destaque. É a mesma regra do protótipo (folio.html).
              color: row.isDone ? AppColors.muted : AppColors.accent,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// EXPLICA: ícone da esquerda. Tamanho fixo de 22x22 nos dois casos, para o
// nome da pasta ficar alinhado igual quando troca de spinner para o ✓.
class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.isDone});

  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: isDone
          ? const Icon(Icons.check, size: 22, color: AppColors.accent)
          : const Padding(
              padding: EdgeInsets.all(2),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            ),
    );
  }
}
