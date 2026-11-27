import 'package:flutter/material.dart';
import 'package:folio/core/app_colors.dart';
import 'package:folio/screens/read_device/scan_models.dart';
import 'package:folio/screens/read_device/widgets/scan_row_tile.dart';
import 'package:folio/widgets/glass.dart';

// EXPLICA: este widget é StatefulWidget porque precisa guardar um
// ScrollController (para rolar a lista por código). Estado que sobrevive
// entre redesenhos fica na classe State, abaixo.
/// Card de vidro com as pastas encontradas. Mostra um loading enquanto o app
/// ainda está listando as pastas e rola sozinho até a pasta mais recente.
class ScanFolderList extends StatefulWidget {
  const ScanFolderList({super.key, required this.state});

  final ScanState state;

  @override
  State<ScanFolderList> createState() => _ScanFolderListState();
}

class _ScanFolderListState extends State<ScanFolderList> {
  // EXPLICA: o ScrollController é o "controle remoto" da lista: com ele
  // dizemos para onde rolar.
  final _scroll = ScrollController();

  // EXPLICA: o Flutter chama didUpdateWidget quando o pai entrega uma versão
  // nova deste widget (aqui, com um ScanState novo). `oldWidget` é a versão
  // anterior, então dá para comparar "antes x depois". Só rolamos quando
  // entrou uma pasta nova, não a cada atualização de contagem.
  @override
  void didUpdateWidget(ScanFolderList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final gotNewRow =
        widget.state.rows.length != oldWidget.state.rows.length;
    if (gotNewRow) _scrollToEnd();
  }

  @override
  void dispose() {
    _scroll.dispose(); // todo controller criado precisa ser liberado
    super.dispose();
  }

  // EXPLICA: não dá para rolar na hora, porque a linha nova ainda não foi
  // medida/desenhada e o "fim da lista" ainda é o antigo. addPostFrameCallback
  // espera o frame atual terminar; aí maxScrollExtent já inclui a linha nova.
  /// Espera o layout da linha nova para saber até onde rolar.
  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return; // a lista pode já ter sido removida
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // EXPLICA: SizedBox com width infinita faz o card ocupar toda a largura.
    // A altura vem do Expanded do pai (read_device_screen.dart).
    return SizedBox(
      width: double.infinity,
      child: GlassBox(
        // EXPLICA: dois modos dentro do mesmo card: loading ou lista.
        child: widget.state.isPreparing ? const _Loading() : _buildList(),
      ),
    );
  }

  Widget _buildList() {
    final rows = widget.state.rows;

    return ScrollConfiguration(
      // Sem barra de rolagem (no Windows ela aparece por padrão).
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.separated(
        controller: _scroll,
        // EXPLICA: o usuário não rola com o dedo; só o código rola. Isso evita
        // briga entre o gesto e o auto-scroll.
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: rows.length,
        // EXPLICA: itemBuilder cria cada linha sob demanda, só as visíveis.
        // `_` nos parâmetros significa "não vou usar este valor".
        itemBuilder: (_, i) => ScanRowTile(row: rows[i]),
        // EXPLICA: o separador é desenhado ENTRE as linhas, então não aparece
        // depois da última.
        separatorBuilder: (_, _) => Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}

// EXPLICA: mostrado enquanto o app lista as pastas (fase "preparando"), para o
// usuário não ver a tela parada.
class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        // EXPLICA: `min` faz a Column ter só a altura do conteúdo, para o
        // Center conseguir centralizá-la no card.
        mainAxisSize: MainAxisSize.min,
        spacing: 16, // espaço entre os filhos (no lugar de SizedBox)
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.accent,
            ),
          ),
          Text(
            'Procurando suas pastas de imagens',
            style: TextStyle(fontSize: 15, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
