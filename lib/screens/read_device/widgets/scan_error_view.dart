import 'package:flutter/material.dart';
import 'package:folio/core/app_colors.dart';
import 'package:folio/widgets/primary_button.dart';

/// Mostrada quando a leitura falha (ex.: sem acesso aos arquivos).
class ScanErrorView extends StatelessWidget {
  const ScanErrorView({super.key, required this.onBack});

  // EXPLICA: o widget não sabe COMO voltar; quem usa ele diz o que fazer ao
  // tocar no botão (callback). Assim ele fica reaproveitável e simples.
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      // EXPLICA: centraliza o conteúdo na vertical, já que a tela de erro
      // não tem lista nem barra para ocupar o espaço.
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Não foi possível ler seu celular',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Sem acesso aos arquivos, o Folio não consegue listar as pastas.',
          style: TextStyle(fontSize: 16, color: AppColors.muted),
        ),
        const SizedBox(height: 20),
        PrimaryButton(label: 'Voltar', onPressed: onBack),
      ],
    );
  }
}
