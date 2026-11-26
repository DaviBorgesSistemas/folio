# Folio, passo a passo

Este guia constrói o app **em passos pequenos**. Cada passo termina com algo que você vê funcionando na tela. O código só aparece quando a necessidade aparece.

Formato de cada passo:

- **O que você vai ver:** o resultado no celular.
- **Por quê:** a decisão ou o problema que o passo resolve.
- **Código:** só o necessário.
- **Conferir:** o que deve acontecer antes de seguir.

Antes de começar, o projeto precisa ter: o `flutter create`, as dependências (`photo_manager`, `shared_preferences`), as permissões do Android/iOS e a fonte no `pubspec.yaml`. Esses passos de preparação estão no [guia completo](guia-folio-flutter.md), seções 1 a 3. As telas de visualizador, editor, copiar, mover e excluir também estão lá, e entram aqui depois.

---

# Parte A: a cara do app

## Passo 1: tema e uma tela

**O que você vai ver:** uma tela escura com a palavra "Folio" no centro, na fonte Plus Jakarta Sans.

**Por quê:** cores e fonte ficam em **um lugar só**. Se amanhã você trocar o azul-violeta por outra cor, muda uma linha e o app inteiro acompanha. As telas nunca escrevem `Color(0xFF...)` direto: elas usam `AppColors`.

`lib/core/theme.dart`:

```dart
import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF121318);
  static const surface = Color(0xFF1E1F25);
  static const surface2 = Color(0xFF292A31);
  static const line = Color(0xFF44454F);          // contornos
  static const text = Color(0xFFE3E1E9);
  static const muted = Color(0xFFC5C5D0);         // texto secundário
  static const accent = Color(0xFFBFC2FF);        // cor principal
  static const onAccent = Color(0xFF272A78);      // texto sobre o accent
  static const secContainer = Color(0xFF3F4165);  // item selecionado
  static const onSecContainer = Color(0xFFDFE0FF);
  static const danger = Color(0xFFFFB4AB);
}

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondaryContainer: AppColors.secContainer,
      onSecondaryContainer: AppColors.onSecContainer,
      outline: AppColors.line,
      surface: AppColors.surface,
      error: AppColors.danger,
    ),
    textTheme: base.textTheme.apply(
      fontFamily: 'PlusJakartaSans',
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
  );
}
```

`buildTheme()` parte do tema escuro padrão do Material 3 e troca só o que o Folio quer diferente (`copyWith`).

`lib/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:folio/core/theme.dart';

class FolioApp extends StatelessWidget {
  const FolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Folio',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const Scaffold(
        body: Center(
          child: Text('Folio',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}
```

`lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:folio/app.dart';

void main() => runApp(const FolioApp());
```

**Conferir:** `flutter run`. Fundo escuro `#121318`, texto claro, fonte arredondada. Se a fonte parecer a padrão do Android, reinicie o app por completo (hot reload não carrega fonte nova) e confira se o `pubspec.yaml` lista os arquivos de `assets/fonts`.

---

## Passo 2: o fundo com manchas de cor

**O que você vai ver:** o fundo deixa de ser liso e ganha manchas suaves de azul-violeta, rosa e turquesa.

**Por quê:** o passo 3 vai criar superfícies de vidro fosco. Vidro desfoca **o que está atrás dele**. Sobre um fundo liso, vira só um retângulo cinza. Então o app precisa de algo colorido atrás de tudo, e esse algo precisa existir **uma vez só**, e não dentro de cada tela.

`lib/widgets/app_background.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:folio/core/theme.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      const Positioned.fill(child: ColoredBox(color: AppColors.bg)),
      _blob(const Alignment(-1, -1.1), const Color(0x577A80FF)), // azul-violeta
      _blob(const Alignment(1.2, -0.3), const Color(0x33FF80BE)), // rosa
      _blob(const Alignment(-0.6, 1.2), const Color(0x333CC8D2)), // turquesa
      child,
    ]);
  }

  /// Uma mancha: um gradiente radial que sai da cor e some em transparente.
  Widget _blob(Alignment at, Color color) => Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
                center: at, radius: 0.9, colors: [color, Colors.transparent]),
          ),
        ),
      );
}
```

Para o fundo valer para **todas** as telas, ele entra no `builder` do `MaterialApp`, que envolve o Navigator inteiro:

```dart
// app.dart
theme: buildTheme(),
builder: (context, child) => AppBackground(child: child!), // novo
home: ...
```

Isso cria um problema: o `Scaffold` pinta `AppColors.bg` por cima do fundo e esconde as manchas. A solução é deixar o `Scaffold` e a `AppBar` **transparentes**. Em `buildTheme()`:

```dart
scaffoldBackgroundColor: Colors.transparent, // era AppColors.bg
...
appBarTheme: const AppBarTheme(
  backgroundColor: Colors.transparent,
  elevation: 0,
  scrolledUnderElevation: 0,
  foregroundColor: AppColors.text,
),
```

Nesse ponto o `import` de `app_background.dart` entra no `app.dart`.

**Conferir:** as manchas aparecem atrás do "Folio". Se o fundo continuar liso, o `Scaffold` ainda está opaco: revise o `scaffoldBackgroundColor`.

---

## Passo 3: a peça de vidro

**O que você vai ver:** "Folio" dentro de um cartão translúcido, com borda clara e fina.

**Por quê:** cards, barras e menus do app vão usar o mesmo efeito. Em vez de repetir `BackdropFilter` em cada tela, fica um widget só, o `GlassBox`.

`lib/widgets/glass.dart`:

```dart
import 'dart:ui';
import 'package:flutter/material.dart';

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
            border: Border.all(color: const Color(0x24FFFFFF)),
          ),
          child: child,
        ),
      ),
    );
  }
}
```

Duas regras que explicam o código:

1. **`ClipRRect` é obrigatório.** O `BackdropFilter` desfoca o que está atrás de tudo o que ele ocupa. Sem o recorte, o desfoque vaza para a tela inteira.
2. **Use com moderação.** Cada `BackdropFilter` custa processamento. Aplique em poucas superfícies grandes (cards, barras), nunca em cada miniatura de uma grade.

Teste no `app.dart`, trocando o `home`:

```dart
home: const Scaffold(
  body: Center(
    child: GlassBox(
      padding: EdgeInsets.all(28),
      child: Text('Folio',
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
    ),
  ),
),
```

**Conferir:** o cartão aparece com a borda clara. O desfoque é sutil porque as manchas já são suaves. O que mostra que funciona é o tom levemente mais claro e a borda. Ele fica mais evidente quando houver capas de fotos atrás, na lista de pastas.

---

## Passo 4: a primeira tela de verdade, com permissão

**O que você vai ver:** uma tela de boas-vindas. Ao tocar em "Permitir acesso às fotos", o Android mostra o diálogo de permissão e um aviso informa o resultado.

**Por quê:** sem permissão, nenhuma imagem aparece, então é a primeira coisa a funcionar. Neste passo a chamada ao `photo_manager` fica **dentro da própria tela**, de propósito: é o jeito mais curto de testar a permissão. No passo 5 ela sai da tela e vai para uma camada própria.

O botão principal, que será usado em várias telas, `lib/widgets/primary_button.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:folio/core/theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          disabledBackgroundColor: AppColors.accent.withAlpha(110),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}
```

`lib/screens/welcome_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:folio/core/theme.dart';
import 'package:folio/widgets/glass.dart';
import 'package:folio/widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _allow(BuildContext context) async {
    final state = await PhotoManager.requestPermissionExtend();
    // Depois de um await, a tela pode já ter saído: confira antes de usar o context.
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.hasAccess ? 'Com acesso às fotos' : 'Sem acesso às fotos')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GlassBox(
                radius: 14,
                padding: EdgeInsets.all(12),
                child: Icon(Icons.photo_library_outlined, color: AppColors.accent),
              ),
              const Spacer(),
              const Text(
                'Suas fotos, separadas por pasta',
                style: TextStyle(fontSize: 31, height: 1.1, fontWeight: FontWeight.w800, letterSpacing: -0.9),
              ),
              const SizedBox(height: 12),
              const Text(
                'O Folio lê as imagens do seu celular e mostra cada pasta em um só lugar.',
                style: TextStyle(fontSize: 16, height: 1.5, color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: 'Permitir acesso às fotos', onPressed: () => _allow(context)),
            ],
          ),
        ),
      ),
    );
  }
}
```

No `app.dart`, `home: const WelcomeScreen()` (e o import).

O ícone no lugar do logo é provisório. O logo em SVG entra mais tarde, junto com a splash.

**Conferir:** use um **celular real**. O emulador quase não tem fotos. Ao tocar no botão, o diálogo do Android aparece. Se negar, o aviso diz "Sem acesso às fotos". Se o diálogo não aparece, as permissões do `AndroidManifest.xml` estão faltando.

> **Mais tarde:** o protótipo também mostra as telas de "Acesso a todos os arquivos" (explicação, folha "Por que precisamos dessa permissão?" e a página de ajustes do Android). Elas não entram neste passo; estão descritas no [guia completo](guia-folio-flutter.md), seção 8, e nos prompts 1b e 1c de [STITCH-PROMPTS.md](STITCH-PROMPTS.md).

---

# Parte B: dados e estado

## Passo 5: ler as pastas

**O que você vai ver:** depois de permitir, o console imprime o nome e a quantidade de imagens de cada pasta, e o aviso mostra quantas pastas existem.

**Por quê:** hoje a tela fala direto com o `photo_manager`. Isso funciona para uma chamada, mas quando houver listar, copiar, mover e excluir, cada tela repetiria o mesmo código e dependeria dos detalhes do pacote. A solução é uma camada fina, o `GalleryService`: **só ele conhece o sistema de fotos**. As telas pedem coisas simples ("lista as pastas") e recebem objetos do próprio app.

O objeto que representa uma pasta, `lib/data/folder_info.dart`:

```dart
import 'package:photo_manager/photo_manager.dart';

class FolderInfo {
  FolderInfo({
    required this.path,
    required this.count,
    required this.covers,
    required this.lastDate,
  });

  final AssetPathEntity path;     // o álbum no sistema
  final int count;                // quantidade de imagens
  final List<AssetEntity> covers; // até 4 imagens para a capa em mosaico
  final DateTime lastDate;        // usado em "Recentes"

  String get id => path.id;
  String get name => path.isAll ? 'Recentes' : path.name;
}
```

O álbum `isAll` é um álbum especial do sistema com **todas** as imagens. O app o chama de "Recentes".

O serviço, por enquanto com três métodos, `lib/data/gallery_service.dart`:

```dart
import 'package:photo_manager/photo_manager.dart';
import 'folder_info.dart';

class GalleryService {
  /// Pede permissão. Devolve true se há acesso (total ou parcial).
  Future<bool> requestPermission() async {
    final state = await PhotoManager.requestPermissionExtend();
    return state.hasAccess;
  }

  /// Lista os álbuns que têm imagens.
  Future<List<AssetPathEntity>> listAlbums() {
    return PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: true, // inclui o álbum "Recentes"
    );
  }

  /// Conta as imagens e pega até 4 capas.
  Future<FolderInfo> describe(AssetPathEntity path) async {
    final count = await path.assetCountAsync;
    final covers = count == 0
        ? <AssetEntity>[]
        : await path.getAssetListRange(start: 0, end: count < 4 ? count : 4);
    return FolderInfo(
      path: path,
      count: count,
      covers: covers,
      lastDate: covers.isEmpty
          ? DateTime.fromMillisecondsSinceEpoch(0)
          : covers.first.createDateTime,
    );
  }
}
```

Agora a tela de boas-vindas usa o serviço em vez do `photo_manager`. Troque o `_allow`:

```dart
static final _service = GalleryService(); // provisório: o passo 6 resolve de onde ele vem

Future<void> _allow(BuildContext context) async {
  final ok = await _service.requestPermission();
  if (!ok || !context.mounted) return;

  final albums = await _service.listAlbums();
  for (final a in albums) {
    final info = await _service.describe(a);
    debugPrint('${info.name}: ${info.count}');
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('${albums.length} pastas')),
  );
}
```

O `_service` é `static` porque o construtor da tela é `const`, e um `const` não aceita um campo comum criado com `GalleryService()`. O passo 6 tira esse campo da tela.

**Conferir:** no console do `flutter run`, os nomes batem com os do app de galeria do celular (Camera, Download, WhatsApp Images...), e as contagens também. Se não batem, é aqui que se descobre, antes de existir qualquer tela de lista.

---

## Passo 6: guardar o resultado para as outras telas

**O que você vai ver:** depois de permitir, o app abre uma segunda tela com a lista de pastas e a quantidade de imagens de cada uma.

**Por quê:** no passo 5 a lista de pastas foi lida e **jogada fora** (era só um `debugPrint`). A próxima tela precisa dela. Como duas telas diferentes precisam da mesma informação, ela não pode morar dentro de nenhuma delas: precisa de um lugar próprio, fora das telas.

O Flutter já traz o necessário, sem pacote: o `ValueNotifier`. Ele guarda um valor e **avisa quem está ouvindo quando o valor é trocado**. A tela ouve com `ValueListenableBuilder` e se reconstrói sozinha.

`lib/state/gallery_controller.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:folio/data/folder_info.dart';
import 'package:folio/data/gallery_service.dart';

class GalleryController {
  final service = GalleryService();

  /// A lista de pastas. A tela ouve este valor.
  final folders = ValueNotifier<List<FolderInfo>>([]);

  Future<bool> requestPermission() => service.requestPermission();

  /// Lê todas as pastas e guarda o resultado.
  Future<void> scan() async {
    final paths = await service.listAlbums();
    final result = <FolderInfo>[];
    for (final p in paths) {
      result.add(await service.describe(p));
    }
    folders.value = result; // trocar o valor avisa a tela
  }
}

/// Uma instância só, usada por todas as telas.
final gallery = GalleryController();
```

Por que uma variável global (`gallery`)? É a forma mais simples de as telas chegarem ao mesmo objeto sem nenhum pacote. O custo é que testar fica um pouco menos direto (veja "Evoluir depois" no fim).

A tela de boas-vindas deixa de conhecer o serviço. Ela pede a permissão, manda ler e navega:

```dart
Future<void> _allow(BuildContext context) async {
  final ok = await gallery.requestPermission();
  if (!ok || !context.mounted) return;

  await gallery.scan();
  if (!context.mounted) return;
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => const FoldersScreen()),
  );
}
```

`pushReplacement` troca a tela em vez de empilhar: voltar não leva às boas-vindas.

`lib/screens/folders_screen.dart` (versão simples, só texto):

```dart
import 'package:flutter/material.dart';
import 'package:folio/core/theme.dart';
import 'package:folio/data/folder_info.dart';
import 'package:folio/state/gallery_controller.dart';

class FoldersScreen extends StatelessWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pastas')),
      body: ValueListenableBuilder<List<FolderInfo>>(
        valueListenable: gallery.folders,
        builder: (context, folders, _) => ListView(
          children: [
            for (final f in folders)
              ListTile(
                title: Text(f.name),
                trailing: Text('${f.count}',
                    style: const TextStyle(color: AppColors.muted)),
              ),
          ],
        ),
      ),
    );
  }
}
```

**Conferir:** a lista mostra as mesmas pastas e contagens do passo 5. Enquanto `scan()` roda, o botão parece parado. Isso é esperado: a tela de leitura com progresso entra depois (seção 9 do guia completo).

---

## Passo 7: ordenar e buscar, e por que o estado vira um objeto

**O que você vai ver:** três botões para ordenar (mais imagens, A–Z, recentes) e um campo de busca que filtra a lista.

**Por quê:** agora a tela depende de **três coisas**: a lista, a ordem e o texto da busca. Seria possível ter três `ValueNotifier`, mas a lista visível depende dos três ao mesmo tempo, e a tela teria de ouvir os três juntos. O jeito mais simples é guardar tudo num **único objeto de estado** e trocar o objeto inteiro a cada mudança.

Esse objeto é **imutável**: seus campos são `final`. Para mudar algo, cria-se um objeto novo com `copyWith`. Isso importa por causa de uma regra do `ValueNotifier`:

> Ele só avisa quando o `value` é **trocado por outro objeto**. Se você mexer dentro do objeto que já está lá (`value.folders.add(...)`), ninguém é avisado e a tela fica desatualizada.

Com estado imutável, esse erro fica impossível: não existe como alterar o objeto antigo.

Troque o conteúdo de `lib/state/gallery_controller.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:folio/data/folder_info.dart';
import 'package:folio/data/gallery_service.dart';

enum FolderSort { count, name, recent }

/// Tudo o que a tela de pastas precisa saber. Imutável.
@immutable
class GalleryState {
  const GalleryState({
    this.folders = const [],
    this.sort = FolderSort.count,
    this.query = '',
  });

  final List<FolderInfo> folders;
  final FolderSort sort;
  final String query;

  /// Cópia com só os campos informados trocados.
  GalleryState copyWith({
    List<FolderInfo>? folders,
    FolderSort? sort,
    String? query,
  }) =>
      GalleryState(
        folders: folders ?? this.folders,
        sort: sort ?? this.sort,
        query: query ?? this.query,
      );

  /// A lista como a tela mostra: filtrada pela busca e na ordem escolhida.
  List<FolderInfo> get visibleFolders {
    final q = query.trim().toLowerCase();
    final list = folders
        .where((f) => q.isEmpty || f.name.toLowerCase().contains(q))
        .toList();
    switch (sort) {
      case FolderSort.count:
        list.sort((a, b) => b.count.compareTo(a.count));
      case FolderSort.name:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case FolderSort.recent:
        list.sort((a, b) => b.lastDate.compareTo(a.lastDate));
    }
    return list;
  }
}

/// O controller agora É um ValueNotifier: o valor dele é o GalleryState.
class GalleryController extends ValueNotifier<GalleryState> {
  GalleryController() : super(const GalleryState());

  final service = GalleryService();

  Future<bool> requestPermission() => service.requestPermission();

  void setSort(FolderSort s) => value = value.copyWith(sort: s);
  void setQuery(String q) => value = value.copyWith(query: q);

  Future<void> scan() async {
    final paths = await service.listAlbums();
    final result = <FolderInfo>[];
    for (final p in paths) {
      result.add(await service.describe(p));
    }
    value = value.copyWith(folders: result);
  }
}

final gallery = GalleryController();
```

Note o que **não mudou**: a tela de boas-vindas continua chamando `gallery.requestPermission()` e `gallery.scan()` do mesmo jeito.

Duas ideias que valem guardar:

- **A "ordem" e o "filtro" não são guardados prontos.** Guarda-se só a escolha (`sort`, `query`), e a lista visível é **calculada** (`visibleFolders`). Assim nunca há duas versões da lista que possam ficar fora de sincronia.
- **As telas só leem o estado e chamam métodos.** Quem muda o estado é o controller, nunca a tela.

`lib/screens/folders_screen.dart`, agora com busca e ordenação:

```dart
import 'package:flutter/material.dart';
import 'package:folio/core/theme.dart';
import 'package:folio/state/gallery_controller.dart';

class FoldersScreen extends StatelessWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pastas')),
      body: ValueListenableBuilder<GalleryState>(
        valueListenable: gallery,
        builder: (context, state, _) {
          final folders = state.visibleFolders;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: TextField(
                  onChanged: gallery.setQuery,
                  decoration: const InputDecoration(
                    hintText: 'Buscar pasta',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                child: SegmentedButton<FolderSort>(
                  expandedInsets: EdgeInsets.zero,
                  segments: const [
                    ButtonSegment(value: FolderSort.count, label: Text('Mais imagens')),
                    ButtonSegment(value: FolderSort.name, label: Text('A–Z')),
                    ButtonSegment(value: FolderSort.recent, label: Text('Recentes')),
                  ],
                  selected: {state.sort},
                  onSelectionChanged: (s) => gallery.setSort(s.first),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    for (final f in folders)
                      ListTile(
                        title: Text(f.name),
                        trailing: Text('${f.count}',
                            style: const TextStyle(color: AppColors.muted)),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

**Conferir:**
1. Tocar em "A–Z" reordena por nome. "Mais imagens" põe a maior pasta no topo.
2. Digitar "cam" mostra só as pastas com "cam" no nome. Apagar o texto traz todas de volta.
3. Se a lista não reage, procure por alguém que **alterou** o estado em vez de trocá-lo (`value.folders.add(...)`).

---

# Onde estamos e o que vem depois

Você tem: tema, fundo, vidro, permissão, leitura das pastas e uma lista que ordena e filtra. Falta ainda o que torna o app útil:

| O que falta | Quando entra | Onde está no guia completo |
|---|---|---|
| Cards de pasta com mosaico de capas | Ao trocar a lista de texto por uma grade | Seção 10 |
| Abrir uma pasta, paginar de 90 em 90, selecionar | Quando a lista de pastas estiver bonita | Seção 11 |
| Favoritos (guardados no `shared_preferences`) | Quando existir uma imagem para favoritar | Seções 7 e 11 |
| Visualizador, zoom, excluir com "Desfazer", copiar, mover | Depois da pasta | Seções 12 e 13 |
| Atualizar quando a galeria muda fora do app | Quando houver o que atualizar | Seção 7, "Mudanças feitas fora do app" |
| Editor de imagem | Por último | Seção 14 |

Cada um desses vai entrar neste mesmo formato: um problema, a decisão, o código mínimo e a conferência.

## Evoluir depois

- **Riverpod:** o estado já é imutável e está em um só lugar. Na migração, `GalleryController` vira um `Notifier<GalleryState>`, `value` passa a ser `state`, `gallery` vira um provider e as telas trocam `ValueListenableBuilder` por `ref.watch`. `GalleryState` e `GalleryService` não mudam.
- **Testes:** a variável global `gallery` dificulta trocar o controller num teste. Quando precisar, passe o controller pelo construtor das telas ou migre para Riverpod.
