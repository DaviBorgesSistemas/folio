// EXPLICA: este arquivo só define os "dados" da tela (modelos). Não tem tela
// nem lógica de leitura aqui. A ideia é que a tela seja sempre um reflexo de
// um ScanState: mudou o estado, a tela se redesenha.

/// Uma pasta encontrada na leitura.
class ScanRow {
  const ScanRow({
    required this.name,
    required this.path,
    required this.count,
    required this.isDone,
  });

  final String name;
  final String path;

  /// Quantidade de imagens (parcial enquanto [isDone] for false).
  final int count;

  /// false = a pasta ainda está sendo lida.
  final bool isDone;
}

/// Retrato do progresso da leitura, usado para desenhar a tela.
class ScanState {
  // EXPLICA: todos os campos têm valor padrão, então `const ScanState()` já
  // representa "começou, nada encontrado ainda". Como a classe é const e todos
  // os campos são final, ela é imutável: para mudar algo, cria-se um novo
  // ScanState (é o que o device_scanner.dart faz a cada passo).
  const ScanState({
    this.found = 0,
    this.progress = 0,
    this.rows = const [],
    this.isPreparing = false,
  });

  // EXPLICA: atalho nomeado para o estado inicial da tela (listando pastas).
  // `static const` = existe uma única instância compartilhada, sem custo.
  /// Antes de ler: ainda listando as pastas do aparelho.
  static const preparing = ScanState(isPreparing: true);

  /// Total de imagens encontradas até agora.
  final int found;

  /// Progresso de 0 a 1.
  final double progress;

  /// Só as pastas que têm imagens.
  final List<ScanRow> rows;

  /// true enquanto o app lista as pastas (ainda não há progresso a mostrar).
  final bool isPreparing;

  // EXPLICA: getters calculados. Evitam repetir `rows.length` e a conta da
  // porcentagem espalhadas pelos widgets.
  int get folderCount => rows.length;
  int get percent => (progress * 100).round();
}
