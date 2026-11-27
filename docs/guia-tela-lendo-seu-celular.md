# Guia: tela "Lendo seu celular"

Arquivo da tela: `lib/screens/read_device/read_device_screen.dart`
Referência visual: `docs/folio.html` (função `startScan`) e as telas do Stitch
`lendo_seu_celular_43` e `lendo_seu_celular_conclu_do`.

> Código de exemplo escrito sem rodar. Use como ponto de partida.

---

## 1. Onde você está

Já pronto: título, número grande, subtítulo, barra, texto "% concluído" e o
`GlassBox` com a lista.

Falta:

- Barra (`widthFactor: 0.6`) e texto ("43%") ainda são fixos.
- Lista tem 5 itens iguais, fixos.
- Falta o ícone de "carregando" na linha em andamento.
- Falta o botão no rodapé.
- Falta a leitura real das pastas.
- Falta o auto-scroll da lista.

---

## 2. Como a tela funciona (protótipo HTML)

Tudo é calculado a partir de um único dado: o progresso da leitura.

| Elemento | Regra |
|---|---|
| Linha concluída | ✓ + nome + contagem final (cor `muted`) |
| Linha em andamento | anel girando + nome + contagem parcial com "…" (cor `accent`) |
| Pasta ainda não lida | não aparece na lista |
| Número grande | soma das contagens (concluídas + parciais) |
| Subtítulo | "imagens encontradas em N pastas" (N = pastas já iniciadas; singular se 1) |
| Barra / texto | porcentagem de progresso |
| Lista | rola sozinha para o fim a cada pasta nova |
| Botão | "Lendo…" desabilitado e esmaecido; no fim vira "Ver pastas encontradas" |

O card da lista ocupa todo o espaço entre o "% concluído" e o botão
(`flex:1; overflow-y:auto`). Se as linhas não couberem, o conteúdo rola e o
card não muda de tamanho.

---

## 3. Leitura real das pastas (`photo_manager`)

O `photo_manager` já está no `pubspec.yaml` e o manifest já tem
`READ_MEDIA_IMAGES` e `READ_EXTERNAL_STORAGE`.

```dart
final paths = await PhotoManager.getAssetPathList(
  type: RequestType.image,
  onlyAll: false, // false = uma entrada por pasta (WhatsApp, Camera...)
);
```

- `AssetPathEntity.name` é o nome da pasta.
- `AssetPathEntity.assetCountAsync` é a contagem (assíncrona).
- `onlyAll: true` devolveria só o álbum "Recent", que junta tudo. Use `false`.
- Total de pastas = `paths.length`. A porcentagem é `pastasLidas / paths.length`.

### Permissão

O `permission_access_controller.dart` pede `manageExternalStorage`, mas o
`photo_manager` usa a permissão de mídia. Antes de listar, chame:

```dart
final state = await PhotoManager.requestPermissionExtend();
if (!state.hasAccess) { /* tratar: mostrar mensagem, voltar */ }
```

No Android 13+ isso mapeia para `READ_MEDIA_IMAGES`. Se o usuário liberar só
parte das fotos (`READ_MEDIA_VISUAL_USER_SELECTED`), as contagens refletem só o
que foi liberado.

---

## 4. Modelos

```dart
class ScanRow {
  ScanRow(this.name, this.count, this.done);
  final String name;
  final int count;
  final bool done; // false = em andamento
}

class ScanState {
  ScanState(this.found, this.pct, this.rows);
  final int found;      // total de imagens encontradas até agora
  final double pct;     // 0..1
  final List<ScanRow> rows;
}
```

---

## 5. Stream da leitura

Lê uma pasta por vez e emite o estado a cada passo.

```dart
Stream<ScanState> scan() async* {
  final paths = await PhotoManager.getAssetPathList(
    type: RequestType.image,
    onlyAll: false,
  );

  var found = 0;
  final rows = <ScanRow>[];

  for (var i = 0; i < paths.length; i++) {
    final p = paths[i];

    // pasta em andamento
    rows.add(ScanRow(p.name, 0, false));
    yield ScanState(found, i / paths.length, List.of(rows));

    final count = await p.assetCountAsync;
    found += count;
    rows[rows.length - 1] = ScanRow(p.name, count, true);
    yield ScanState(found, (i + 1) / paths.length, List.of(rows));
  }
}
```

### Cuidados com dados reais

- **Contagem rápida demais:** `assetCountAsync` pode responder em poucos
  milissegundos, e a tela passa batido (sem o anel girando e sem o contador
  subindo). Se quiser a animação do protótipo, faça o número subir de 0 até
  `count` com um `TweenAnimationBuilder<int>` na linha. Se preferir, deixe
  instantâneo.
- **Pastas vazias:** filtre as que têm `count == 0`.
- **Ordem:** o sistema devolve na ordem dele. Use `paths.sort(...)` se quiser
  outra (por contagem, por nome...).
- **Erros:** trate `snapshot.hasError` e mostre uma mensagem, senão o botão
  fica preso em "Lendo…".
- **Guardar o resultado:** a tela de pastas vai precisar da lista. Guarde os
  `AssetPathEntity` num `provider` (já está no pubspec) em vez de ler tudo de
  novo.

---

## 6. A tela

`StatefulWidget`. Crie o stream **uma vez** no `initState`, senão ele recomeça
a cada rebuild.

```dart
class ReadDeviceScreen extends StatefulWidget {
  const ReadDeviceScreen({super.key});
  @override
  State<ReadDeviceScreen> createState() => _ReadDeviceScreenState();
}

class _ReadDeviceScreenState extends State<ReadDeviceScreen> {
  late final Stream<ScanState> _stream = scan();
  final _scroll = ScrollController();
  int _lastRows = 0;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // Rola para o fim só quando entra uma linha nova.
  void _autoScroll(int rows) {
    if (rows == _lastRows) return;
    _lastRows = rows;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: StreamBuilder<ScanState>(
            stream: _stream,
            builder: (context, snap) {
              final s = snap.data ?? ScanState(0, 0, const []);
              final done = snap.connectionState == ConnectionState.done;
              _autoScroll(s.rows.length);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // título 'Lendo seu celular'
                  // número: fmt(s.found)
                  // subtítulo: 'imagens encontradas em ${s.rows.length} pastas'
                  // barra: FractionallySizedBox(widthFactor: s.pct, ...)
                  // texto: '${(s.pct * 100).round()}% concluído'
                  const SizedBox(height: 20),
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: GlassBox(
                        child: ListView.separated(
                          controller: _scroll,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: s.rows.length,
                          itemBuilder: (_, i) => _ScanRowTile(s.rows[i]),
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: done ? 'Ver pastas encontradas' : 'Lendo…',
                    onPressed: done
                        ? () {
                            // pushReplacement(FadeRoute(PastasScreen()))
                          }
                        : null,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
```

### Por que cada coisa

- **`Expanded` em volta do `GlassBox`:** dá altura ao card e empurra o botão
  para o rodapé. Sem isso o `ListView` não tem altura limitada. É o
  `shrinkWrap: true` atual que faz o card ter a altura do conteúdo.
- **`SizedBox(width: double.infinity)`:** garante a largura total do card.
- **`_autoScroll` no `builder`:** só dispara quando a quantidade de linhas
  muda, não a cada frame.
- **`NeverScrollableScrollPhysics`:** evita brigar com o auto-scroll. A leitura
  dura poucos segundos.
- **`SafeArea`:** mantém o botão acima da barra de navegação do sistema.

---

## 7. A linha da lista

```dart
class _ScanRowTile extends StatelessWidget {
  const _ScanRowTile(this.row);
  final ScanRow row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: row.done
                ? const Icon(Icons.check, size: 22, color: AppColors.accent)
                : const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              row.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            row.done ? fmt(row.count) : '${fmt(row.count)}…',
            style: TextStyle(
              fontSize: 15,
              color: row.done ? AppColors.muted : AppColors.accent,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
```

Imports: `dart:ui` (para `FontFeature`), `GlassBox`, `PrimaryButton`,
`AppColors` e o formatador de milhar. Veja se `lib/core/format.dart` já tem o
`fmt`.

---

## 8. Ajustes em outros arquivos

### `lib/widgets/primary_button.dart`

Hoje a cor desabilitada é igual à habilitada. No design o "Lendo…" aparece
esmaecido (o HTML usa `opacity: .55`):

```dart
disabledBackgroundColor:
    filled ? AppColors.accent.withValues(alpha: 0.55) : Colors.transparent,
disabledForegroundColor: foreground.withValues(alpha: 0.55),
```

### Barra de rolagem (só em teste no Windows)

No Android e no iOS o Flutter não mostra barra. No Windows ela aparece. Para
esconder, envolva o `ListView` em:

```dart
ScrollConfiguration(
  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
  child: ListView.separated(...),
)
```

### Navegação

O botão faz `pushReplacement(FadeRoute(...))` para a tela de pastas. No HTML ele
também limpa a pilha, para o voltar não retornar à leitura.

---

## 9. Ordem sugerida

1. Criar `ScanRow` e `ScanState`.
2. Escrever o `scan()` e imprimir no console (`debugPrint`) o que ele emite,
   para validar a leitura real antes de mexer na UI.
3. Trocar a tela para `StatefulWidget` + `StreamBuilder` e ligar número,
   subtítulo, barra e porcentagem.
4. Trocar o `ListView` fixo pelo dinâmico, com `Expanded` e o
   `_ScanRowTile`.
5. Auto-scroll.
6. Botão (e o ajuste do `PrimaryButton`).
7. Tratar permissão negada e erro do stream.
8. Guardar o resultado num `provider` e navegar para a tela de pastas.

## 10. Para testar

- Janela/aparelho com **poucas pastas** (as linhas cabem): o card deve ocupar o
  espaço livre e o botão ficar no rodapé.
- Janela **baixa** (as linhas não cabem): a lista deve rolar até a última pasta.
  Se não rolar até o fim, o `animateTo` está rodando antes do layout, e o
  `postFrameCallback` precisa estar no lugar.
- Permissão negada: não pode travar em "Lendo…".
