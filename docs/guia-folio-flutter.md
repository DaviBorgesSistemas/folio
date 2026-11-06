# Folio em Flutter: guia passo a passo

App de galeria que lê as imagens reais do celular, separa por pasta, abre cada imagem em um visualizador e tem editor. Este guia reproduz o protótipo `folio.html`, tela por tela.

**Sumário**

0. O que você vai construir (inclui "Como o app funciona" e a "Ordem de implementação")
1. Criar o projeto
2. Dependências
3. Permissões (Android e iOS)
4. Estrutura de pastas
5. Tema e utilitários
6. Camada de dados: serviço da galeria
7. Estado: controller
8. Telas 0 e 1: splash, boas-vindas e permissão
9. Tela 2: leitura das imagens
10. Tela 3: lista de pastas
11. Tela 4: dentro da pasta
12. Tela 5: visualizador
13. Ações do visualizador (favoritar, excluir, copiar, mover, compartilhar)
14. Tela 6: editor de imagem
15. Rodar, testar e publicar
16. Armadilhas comuns
17. Evoluções
- Apêndice A: editor próprio (sem `pro_image_editor`)
- Referências

---

## 0. O que você vai construir

| Protótipo HTML | Flutter |
|---|---|
| Splash (some sozinha em ~2 s, toque pula) | `SplashScreen` com `Timer` |
| Boas-vindas / permissão ("Permitir" e "Agora não") | `WelcomeScreen` + `PhotoManager.requestPermissionExtend()` |
| Leitura das imagens | `ScanScreen` + `PhotoManager.getAssetPathList()` |
| Pastas (grade 2 colunas, ordenar, buscar, pasta **Favoritas**) | `FoldersScreen` + `GalleryController` |
| Dentro da pasta (grade de 3 colunas, menu ⋮ com Selecionar e ordem, favoritar, excluir com Desfazer) | `FolderScreen` com paginação |
| Visualizador em tela cheia (deslizar, zoom com pinça e toque duplo, favoritar, info, menu Mais) | `ViewerScreen` com `PageView` + `InteractiveViewer` |
| Editor (cortar, filtros, ajustes, desenhar, texto) | `EditorScreen` com `pro_image_editor` |

A palavra-chave do app é **álbum**: no Android e no iOS, cada pasta de imagens aparece como um `AssetPathEntity`. O pacote `photo_manager` lista esses álbuns com a contagem de imagens, que é exatamente o que a tela "Pastas" precisa.

O que **não** dá para fazer do mesmo jeito que no protótipo, e como resolver:

| Recurso | Situação no Flutter |
|---|---|
| Favoritar | O `photo_manager` não documenta favoritar no Android. Guarde os favoritos no próprio app (`shared_preferences`). |
| Mover para outra pasta | `moveAssetToAnother` não funciona no Android 11+ (API 30+). Use copiar + excluir. |
| Renomear | Exige consentimento do sistema (MediaStore). Deixe fora da v1. |
| Bloquear, Abrir com, Definir como, Imprimir | Fora da v1 (no protótipo são só avisos "simulado"). Veja a seção 17. |
| Botão "+" (pasta Importadas) | Existe só no protótipo, para testar o editor no navegador. No app real as fotos já estão no aparelho. |

### Como o app funciona

Quem guarda as imagens é o sistema (Android ou iOS), não o app. O Folio só **pede permissão, lê e mostra**. Isso define a arquitetura:

```
Sistema (MediaStore / Fotos)
        │  photo_manager
        ▼
GalleryService     fala com o sistema: permissão, álbuns, copiar, mover, excluir
        ▼
GalleryController  guarda a lista de pastas, ordenação, busca e favoritos
        ▼
Telas              só desenham o que o controller entrega
```

O caminho do usuário é este:

1. **Permissão:** sem ela, nenhuma imagem aparece.
2. **Leitura:** o app lista os álbuns e conta as imagens de cada um (uma vez).
3. **Pastas → pasta → imagem:** cada tela abre a seguinte e carrega só o que precisa (miniaturas, 90 imagens por vez).
4. **Mudanças fora do app:** o usuário pode tirar, baixar ou apagar fotos por outro app. O controller percebe isso e se atualiza (seção 7).

Regras que valem para o app inteiro:

- **Miniatura na lista, imagem grande só no visualizador.** Carregar o original na grade trava o app.
- **Tudo é assíncrono.** Ler álbuns, excluir e copiar demoram; a tela precisa tolerar o "ainda carregando".
- **Depois de qualquer ação que muda a galeria, chame `refresh()`.**
- **Só os favoritos são dados do app.** O resto vem do sistema. A pasta **Favoritas** é virtual: junta os ids favoritos de todas as pastas.
- **Excluir sempre com "Desfazer"**, em vez de um diálogo de confirmação.

### Ordem de implementação

Siga a ordem abaixo. Em cada etapa há um ponto de conferência: só avance quando ele funcionar.

| Etapa | Seção | O que fazer | Conferência |
|---|---|---|---|
| 1 | 1 | Criar o projeto | O app padrão abre no celular |
| 2 | 2 e 3 | Dependências e permissões | `flutter pub get` sem erro e o app ainda abre |
| 3 | 4 e 5 | Pastas, tema e utilitários | Compila, sem erros no analisador |
| 4 | 6 e 7 | Serviço, controller, `main.dart` e `app.dart` | Compila e abre uma tela vazia |
| 5 | 8 | Splash e boas-vindas | "Permitir" mostra o diálogo do Android |
| 6 | 9 | Tela de leitura | A contagem sobe e o botão libera no fim |
| 7 | 10 | Lista de pastas | Mesmos nomes e contagens do app de galeria do celular |
| 8 | 11 | Dentro da pasta | Rola sem travar, segura para selecionar, o menu ⋮ muda a ordem |
| 9 | 12 e 13 | Visualizador e ações | Desliza, dá zoom (pinça e toque duplo), favorita, exclui com Desfazer, copia e move |
| 10 | 14 | Editor | Salvar cria a cópia `..._editada.jpg` na pasta |
| 11 | 7 | Mudanças fora do app | Tire uma foto com a câmera e volte ao Folio: ela aparece |
| 12 | 10 | Pasta Favoritas | Favorite duas imagens de pastas diferentes: as duas aparecem em Favoritas |

O roteiro de testes completo está na seção 15.

---

## 1. Criar o projeto

Pré-requisitos: Flutter instalado (`flutter doctor` sem erros), Android Studio com SDK, e **um celular real** com a depuração USB ligada. O emulador quase não tem fotos, então teste no aparelho.

```bash
flutter create folio --platforms=android,ios
cd folio
flutter run   # confirma que o app padrão abre no celular
```

O nome do pacote é `folio`, então os imports abaixo usam `package:folio/...`.

---

## 2. Dependências

Use o comando abaixo para pegar sempre as versões mais recentes compatíveis com o seu Flutter:

```bash
flutter pub add photo_manager photo_manager_image_provider provider shared_preferences pro_image_editor share_plus flutter_svg
```

| Pacote | Para quê |
|---|---|
| `photo_manager` | Ler álbuns e imagens, excluir, copiar, salvar |
| `photo_manager_image_provider` | Widget `AssetEntityImage` (miniaturas com cache) |
| `provider` | Estado simples com `ChangeNotifier` |
| `shared_preferences` | Guardar favoritos |
| `pro_image_editor` | Editor pronto: cortar, girar, filtros, ajustes, desenho, texto |
| `share_plus` | Compartilhar a imagem |
| `flutter_svg` | Mostrar o logo do Folio (arquivo SVG) na splash e nas boas-vindas |

Depois rode `flutter pub get`.

---

## 3. Permissões (Android e iOS)

### 3.1 Android

Edite `android/app/src/main/AndroidManifest.xml`, dentro de `<manifest>` e **antes** de `<application>`:

```xml
<!-- Android 13+ -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
<!-- Android 14+: acesso parcial -->
<uses-permission android:name="android.permission.READ_MEDIA_VISUAL_USER_SELECTED"/>
<!-- Android 12 ou menor -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="29"/>
<!-- Ler a localização (EXIF) das fotos originais -->
<uses-permission android:name="android.permission.ACCESS_MEDIA_LOCATION"/>
```

Segundo a documentação do `photo_manager`, no Android 13 as duas permissões `READ_MEDIA_IMAGES` e `READ_MEDIA_VIDEO` são necessárias mesmo que o app só peça imagens.

Confira também no README do pacote a exigência de `minSdk` e de `compileSdk`. Nos projetos novos, esses valores ficam em `android/app/build.gradle` (ou `build.gradle.kts`).

### 3.2 iOS

Edite `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>O Folio precisa ler suas fotos para mostrar as pastas.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>O Folio salva as imagens editadas na sua galeria.</string>
```

---

## 4. Estrutura de pastas

```
assets/
  folio-mark.svg
  icon/
    folio-icon.png
lib/
  main.dart
  app.dart
  core/
    theme.dart
    format.dart
  data/
    folder_info.dart
    gallery_service.dart
  state/
    gallery_controller.dart
  widgets/
    primary_button.dart
    app_background.dart
    glass.dart
    folder_card.dart
  screens/
    splash_screen.dart
    welcome_screen.dart
    scan_screen.dart
    folders_screen.dart
    folder_screen.dart
    viewer_screen.dart
    editor_screen.dart
```

---

## 5. Tema e utilitários

### `lib/core/theme.dart`

#### Identidade visual: Material Design 3 com vidro fosco

O protótipo combina duas ideias, para não parecer nem um app Material padrão nem um clone de outro estilo:

| Material Design 3 (a estrutura) | Vidro fosco / *glassmorphism* (a superfície) |
|---|---|
| Esquema de cores tonal (`primary`, `secondaryContainer`, `outline`) | Fundo com gradientes coloridos e borrados, que aparecem por trás das telas |
| Botão segmentado (`SegmentedButton`) com check no item ativo | Cards de pasta, barras e menus **translúcidos**, com desfoque do que está atrás |
| Botão principal em pílula e cantos grandes (28) | Borda fina clara e brilho no topo de cada superfície de vidro |
| `SnackBar` com ação, menu ⋮, folhas inferiores | Barra de ações **flutuante** sobre a imagem, no visualizador |
| Botão flutuante (FAB) só no protótipo, para importar fotos de teste | O desfoque só funciona porque há conteúdo colorido atrás |

Duas regras fazem o vidro funcionar:

1. **Precisa ter o que desfocar.** Por isso o app tem um fundo com manchas de cor (`AppBackground`) e as telas ficam com fundo transparente. Sobre um fundo liso, o vidro vira só um retângulo cinza.
2. **Use com moderação.** Cada `BackdropFilter` custa processamento. Aplique em poucas superfícies grandes (barras, cards), não em cada miniatura da grade.

A paleta é o esquema escuro do Material 3 com acento azul-violeta. Troque `accent` e `secContainer` e o app inteiro acompanha.

As mesmas cores do protótipo:

```dart
import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF121318);
  static const surface = Color(0xFF1E1F25);
  static const surface2 = Color(0xFF292A31);
  static const line = Color(0xFF44454F);          // contorno (outline)
  static const text = Color(0xFFE3E1E9);
  static const muted = Color(0xFFC5C5D0);
  static const accent = Color(0xFFBFC2FF);        // primary
  static const onAccent = Color(0xFF272A78);
  static const secContainer = Color(0xFF3F4165);  // item selecionado, chips ativos
  static const onSecContainer = Color(0xFFDFE0FF);
  static const danger = Color(0xFFFFB4AB);
}

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    // Transparente: quem pinta o fundo é o AppBackground (veja abaixo).
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondaryContainer: AppColors.secContainer,
      onSecondaryContainer: AppColors.onSecContainer,
      outline: AppColors.line,
      surface: AppColors.surface,
      error: AppColors.danger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.text,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
  );
}
```

Para usar a fonte Plus Jakarta Sans do protótipo, adicione o pacote `google_fonts` e aplique no `textTheme`. É opcional.

### Logo e ícone do app (`folio-mark.svg` e `folio-icon.svg`)

O Folio tem **dois desenhos**, do mesmo tema (cartões de fotos em leque, com uma paisagem no da frente), para dois usos:

| Arquivo | Para quê | Por quê |
|---|---|---|
| [folio-mark.svg](folio-mark.svg) | Logo **dentro do app** (splash e boas-vindas) | Sem fundo próprio: fica sobre uma peça de vidro escura, combinando com o resto da interface |
| [folio-icon.svg](folio-icon.svg) | Ícone na **tela inicial do celular** | Tem o fundo em gradiente azul-violeta e os cantos arredondados, para se destacar entre os outros apps |

Um quadrado claro de lançador dentro de uma tela escura de vidro destoa. Por isso o app usa a marca, não o ícone.

**1. Logo dentro do app.** Copie `folio-mark.svg` para `assets/folio-mark.svg` e declare no `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/folio-mark.svg
```

Mostre a marca dentro de uma peça de vidro (`GlassBox`, seção 5), como nas seções 8 em diante:

```dart
GlassBox(
  radius: 36,
  padding: const EdgeInsets.all(4),
  tint: const Color(0x1AFFFFFF),
  child: SvgPicture.asset('assets/folio-mark.svg', width: 112, height: 112),
)
```

**2. Ícone na tela inicial.** O Android e o iOS pedem PNG, não SVG. O arquivo [folio-icon.png](folio-icon.png) (1024 × 1024) já está pronto: copie para `assets/icon/folio-icon.png` e use o pacote `flutter_launcher_icons`:

```bash
flutter pub add --dev flutter_launcher_icons
```

```yaml
# pubspec.yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/folio-icon.png"
  remove_alpha_ios: true   # o iOS não aceita ícone com transparência
```

```bash
dart run flutter_launcher_icons
```

**3. Splash nativa (opcional):** a tela que aparece antes de o Flutter abrir. Use o pacote `flutter_native_splash` com a cor de fundo `#121318`.

O ícone já vem com os cantos arredondados desenhados. O Android recorta o ícone no formato do aparelho, então confira como fica no seu celular; se cortar demais, exporte uma versão com mais margem.

### `lib/core/format.dart`

```dart
/// 10917 -> "10.917"
String fmt(int n) => n
    .toString()
    .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

String _two(int n) => n.toString().padLeft(2, '0');

/// "Hoje 14:20", "Ontem 23:04" ou "03/11/2026"
String dayLabel(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  final hm = '${_two(d.hour)}:${_two(d.minute)}';
  if (diff == 0) return 'Hoje $hm';
  if (diff == 1) return 'Ontem $hm';
  return '${_two(d.day)}/${_two(d.month)}/${d.year}';
}

String fullDate(DateTime d) =>
    '${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';

String sizeLabel(int bytes) {
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(2).replaceAll('.', ',')} KB';
  return '${(kb / 1024).toStringAsFixed(2).replaceAll('.', ',')} MB';
}
```

### `lib/widgets/app_background.dart`

O fundo com manchas de cor, atrás de todas as telas. É ele que dá o que desfocar ao vidro.

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

  /// Uma mancha de cor que esmaece até ficar transparente.
  Widget _blob(Alignment at, Color color) => Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(center: at, radius: 0.9, colors: [color, Colors.transparent]),
          ),
        ),
      );
}
```

Use no `app.dart`, com o `builder` do `MaterialApp`, para valer para todas as telas:

```dart
MaterialApp(
  // ...
  builder: (context, child) => AppBackground(child: child!),
)
```

### `lib/widgets/glass.dart`

Dois widgets de vidro: `GlassBox` (qualquer superfície) e `GlassBar` (a barra flutuante de baixo). O `BackdropFilter` desfoca o que está atrás dele; o `ClipRRect` é obrigatório, senão o desfoque vaza para a tela inteira.

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:folio/core/theme.dart';

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
            border: Border.all(color: const Color(0x24FFFFFF)), // borda clara e fina
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Barra flutuante com vidro, usada no visualizador (ações) e na pasta (seleção).
class GlassBar extends StatelessWidget {
  const GlassBar({super.key, required this.child, this.height = 68});
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: SizedBox(
        height: height,
        child: GlassBox(
          radius: 28,
          tint: const Color(0x9E22232C), // mais escuro: precisa ler bem sobre fotos
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: child,
        ),
      ),
    );
  }
}
```

Dentro da barra ficam botões com ícone e rótulo. O mesmo widget serve para a barra do visualizador e para a de seleção da pasta. Com `onTap` nulo, o botão aparece apagado e não responde.

```dart
class BarAction extends StatelessWidget {
  const BarAction(this.icon, this.label, this.onTap, {super.key, this.color});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = onTap == null ? AppColors.muted.withAlpha(110) : (color ?? AppColors.text);
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: c),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: c)),
        ]),
      ),
    );
  }
}
```

### `lib/widgets/primary_button.dart`

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

---

## 6. Camada de dados: serviço da galeria

### `lib/data/folder_info.dart`

```dart
import 'package:photo_manager/photo_manager.dart';

class FolderInfo {
  FolderInfo({
    required this.path,
    required this.count,
    required this.covers,
    required this.lastDate,
  });

  final AssetPathEntity path;   // o álbum no sistema
  final int count;              // quantidade de imagens
  final List<AssetEntity> covers; // até 4 imagens para a capa em mosaico
  final DateTime lastDate;      // usado em "Recentes"

  String get id => path.id;
  String get name => path.isAll ? 'Recentes' : path.name;
}
```

### `lib/data/gallery_service.dart`

```dart
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'folder_info.dart';

class GalleryService {
  /// Pede permissão. Devolve true se há acesso (total ou parcial).
  Future<bool> requestPermission() async {
    final state = await PhotoManager.requestPermissionExtend();
    return state.hasAccess;
  }

  /// Lista os álbuns que têm imagens. Por padrão, o pacote ordena
  /// por data de criação, da mais nova para a mais antiga.
  Future<List<AssetPathEntity>> listAlbums() {
    return PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: true, // inclui o álbum "Recentes" (todas as imagens)
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

  /// Copia a imagem para outra pasta. Se `copyAssetToPath` falhar,
  /// regrava os bytes na pasta de destino.
  Future<AssetEntity?> copyTo(AssetEntity asset, AssetPathEntity target) async {
    try {
      final copied = await PhotoManager.editor
          .copyAssetToPath(asset: asset, pathEntity: target);
      if (copied != null) return copied;
    } catch (_) {}
    final bytes = await asset.originBytes;
    if (bytes == null) return null;
    final title = await asset.titleAsync;
    return PhotoManager.editor.saveImage(
      bytes,
      filename: title.isEmpty
          ? 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg'
          : title,
      relativePath: 'Pictures/${target.name}', // só vale no Android
    );
  }

  /// Move a imagem. No Android 10 ou menor tenta mover direto.
  /// No Android 11+ (e no iOS) copia e depois exclui.
  Future<bool> moveTo(
      AssetEntity asset, AssetPathEntity target) async {
    if (Platform.isAndroid) {
      try {
        final ok = await PhotoManager.editor.android
            .moveAssetToAnother(entity: asset, target: target);
        if (ok) return true;
      } catch (_) {}
    }
    final copy = await copyTo(asset, target);
    if (copy == null) return false;
    final deleted = await PhotoManager.editor.deleteWithIds([asset.id]);
    return deleted.isNotEmpty;
  }

  /// Exclui. No Android 11+ o sistema mostra a própria confirmação.
  Future<List<String>> delete(List<String> ids) =>
      PhotoManager.editor.deleteWithIds(ids);
}
```

> Os nomes dos parâmetros (`filename`, `relativePath`, `entity`, `target`) seguem a versão 3.x do `photo_manager`. Se o compilador reclamar de algum, abra o autocompletar da IDE: a assinatura da sua versão aparece ali.

---

## 7. Estado: controller

### `lib/state/gallery_controller.dart`

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show MethodCall;
import 'package:flutter/widgets.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:folio/data/folder_info.dart';
import 'package:folio/data/gallery_service.dart';

enum FolderSort { count, name, recent }

class ScanProgress {
  const ScanProgress({
    required this.done,
    required this.total,
    required this.images,
    required this.current,
  });
  final int done, total, images;
  final String current;
}

class GalleryController extends ChangeNotifier with WidgetsBindingObserver {
  final service = GalleryService();

  List<FolderInfo> _folders = [];
  FolderSort sort = FolderSort.count;
  String query = '';
  Set<String> _favorites = {};
  static const _favKey = 'favorites';

  // ---------- pastas ----------
  List<FolderInfo> get folders => _folders;

  int get totalImages {
    final all = _folders.where((f) => f.path.isAll);
    if (all.isNotEmpty) return all.first.count;
    return _folders.fold(0, (s, f) => s + f.count);
  }

  List<FolderInfo> get visibleFolders {
    final q = query.trim().toLowerCase();
    final list = _folders
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

  void setSort(FolderSort s) {
    sort = s;
    notifyListeners();
  }

  void setQuery(String q) {
    query = q;
    notifyListeners();
  }

  // ---------- leitura ----------
  Future<bool> requestPermission() => service.requestPermission();

  Future<void> scan({void Function(ScanProgress p)? onProgress}) async {
    final paths = await service.listAlbums();
    final result = <FolderInfo>[];
    var images = 0;
    for (var i = 0; i < paths.length; i++) {
      final info = await service.describe(paths[i]);
      result.add(info);
      if (!info.path.isAll) images += info.count;
      onProgress?.call(ScanProgress(
        done: i + 1,
        total: paths.length,
        images: images,
        current: info.name,
      ));
    }
    _folders = result;
    notifyListeners();
    _updateFavorites(); // capas e contagem de Favoritas
  }

  /// Chame depois de excluir, copiar, mover ou salvar.
  /// Várias chamadas seguidas viram uma só (debounce), e nunca rodam duas
  /// leituras ao mesmo tempo.
  Future<void> refresh() async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      if (_refreshing) {
        _again = true; // chegou outra mudança durante a leitura
        return;
      }
      _refreshing = true;
      try {
        await scan();
        revision++; // avisa as telas abertas para recarregarem
        notifyListeners();
      } finally {
        _refreshing = false;
        if (_again) {
          _again = false;
          refresh();
        }
      }
    });
  }

  // ---------- mudanças feitas fora do app ----------
  Timer? _debounce;
  bool _refreshing = false, _again = false, _watching = false;
  int revision = 0; // sobe a cada atualização da galeria

  /// Chame uma vez, depois que a permissão foi concedida.
  void watchGallery() {
    if (_watching) return;
    _watching = true;
    PhotoManager.addChangeCallback(_onSystemChange);
    PhotoManager.startChangeNotify();
    WidgetsBinding.instance.addObserver(this);
  }

  void _onSystemChange(MethodCall _) => refresh();

  /// Ao voltar para o app, confere de novo: o aviso do sistema nem sempre
  /// chega com o app em segundo plano.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  @override
  void dispose() {
    PhotoManager.removeChangeCallback(_onSystemChange);
    PhotoManager.stopChangeNotify();
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    super.dispose();
  }

  // ---------- favoritos (guardados no app) ----------
  int favRevision = 0;                 // sobe quando as favoritas mudam
  List<AssetEntity> favCovers = [];    // até 4 capas da pasta "Favoritas"
  int get favoritesCount => _favorites.length;

  Future<void> loadFavorites() async {
    final p = await SharedPreferences.getInstance();
    _favorites = (p.getStringList(_favKey) ?? []).toSet();
    notifyListeners();
    // As capas de Favoritas são calculadas depois da leitura (fim do scan),
    // quando já existe permissão para consultar as imagens.
  }

  bool isFavorite(String assetId) => _favorites.contains(assetId);

  /// Busca as imagens favoritas, da mais nova para a mais antiga.
  /// Favoritas que não existem mais no aparelho (apagadas por outro app)
  /// são removidas da lista, mas só com acesso total às fotos: com acesso
  /// parcial, uma imagem "não encontrada" pode só não ter sido liberada.
  Future<List<AssetEntity>> favoriteAssets() async {
    final found = <AssetEntity>[];
    final gone = <String>[];
    for (final id in _favorites) {
      final a = await AssetEntity.fromId(id);
      a == null ? gone.add(id) : found.add(a);
    }
    final full = await PhotoManager.requestPermissionExtend() == PermissionState.authorized;
    if (gone.isNotEmpty && full) {
      _favorites.removeAll(gone);
      await _saveFavorites();
    }
    found.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));
    return found;
  }

  Future<void> _updateFavorites() async {
    favCovers = (await favoriteAssets()).take(4).toList();
    favRevision++;
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_favKey, _favorites.toList());
  }

  /// Favorita vários de uma vez (barra de seleção). Se todos já são
  /// favoritos, remove; senão, adiciona todos. Devolve true se adicionou.
  Future<bool> toggleFavorites(Iterable<String> ids) async {
    final add = !ids.every(_favorites.contains);
    add ? _favorites.addAll(ids) : _favorites.removeAll(ids);
    notifyListeners();
    await _saveFavorites();
    _updateFavorites();
    return add;
  }

  Future<void> toggleFavorite(String assetId) async {
    _favorites.contains(assetId)
        ? _favorites.remove(assetId)
        : _favorites.add(assetId);
    notifyListeners();
    await _saveFavorites();
    _updateFavorites();
  }

  // ---------- excluir com "Desfazer" ----------
  final _pending = <String>{};

  /// Imagens que o usuário excluiu mas ainda podem voltar (aviso na tela).
  /// As telas devem esconder estes ids.
  bool isPending(String id) => _pending.contains(id);

  /// Esconde as imagens e mostra "Desfazer" por 5 s. Só quando o aviso fecha
  /// sem o usuário desfazer é que a exclusão acontece de verdade.
  /// No Android 11+ o diálogo de confirmação do sistema aparece nesse momento.
  void deleteWithUndo(BuildContext context, List<String> ids) {
    _pending.addAll(ids);
    revision++;
    notifyListeners();

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar(); // se havia outro aviso, ele confirma agora
    messenger
        .showSnackBar(SnackBar(
          content: Text(ids.length > 1 ? '${ids.length} imagens excluídas' : 'Imagem excluída'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () {
              _pending.removeAll(ids);
              revision++;
              notifyListeners();
            },
          ),
        ))
        .closed
        .then((reason) async {
      if (reason == SnackBarClosedReason.action) return;
      await service.delete(ids); // vazio = o usuário negou no diálogo do sistema
      _pending.removeAll(ids);
      refresh(); // se negou, as imagens voltam; se excluiu, somem de vez
    });
  }
}
```

### Mudanças feitas fora do app

Depois da primeira leitura, a galeria continua mudando: o usuário tira uma foto, baixa uma imagem, apaga algo pelo app de galeria do celular. Se o Folio só lesse uma vez, ficaria desatualizado. O controller acima cobre três casos:

| Situação | Como o app descobre |
|---|---|
| Mudança com o app aberto | `PhotoManager.addChangeCallback` + `startChangeNotify` (o sistema avisa) |
| Mudança com o app em segundo plano | `didChangeAppLifecycleState(resumed)`: ao voltar, lê de novo |
| Mudança feita pelo próprio app (excluir, copiar, mover, editar) | Quem fez a ação chama `refresh()` |

Detalhes que evitam problemas:

- **Debounce de 600 ms.** Tirar uma foto ou apagar 30 de uma vez dispara vários avisos seguidos. Sem o debounce, o app releria as pastas 30 vezes.
- **Uma leitura por vez.** Se chega um aviso durante a leitura, ela termina e roda mais uma (`_again`).
- **`revision`.** É um contador que sobe a cada atualização. As telas abertas (como `FolderScreen`) o observam e recarregam a própria lista. Sem isso, a pasta continuaria mostrando imagens apagadas.
- **Atualização silenciosa.** Aqui `refresh()` não passa pela `ScanScreen`: a lista só troca quando a nova leitura termina, sem tela de carregamento.
- **Favoritos órfãos.** Se uma imagem favorita é apagada fora do app, o id dela fica no `shared_preferences`. O `favoriteAssets()` limpa esses ids sozinho, mas só com acesso total às fotos. Com acesso parcial, ele não apaga nada, porque a imagem pode estar fora do que o usuário liberou.

Ative a observação uma vez, logo depois de a permissão ser concedida. Na `ScanScreen`, depois do `scan()`, chame `context.read<GalleryController>().watchGallery();` (a chamada é segura se repetida).

### `lib/main.dart` e `lib/app.dart`

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:folio/app.dart';
import 'package:folio/state/gallery_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => GalleryController()..loadFavorites(),
      child: const FolioApp(),
    ),
  );
}
```

```dart
// app.dart
import 'package:flutter/material.dart';
import 'package:folio/core/theme.dart';
import 'package:folio/screens/splash_screen.dart';
import 'package:folio/widgets/app_background.dart';

class FolioApp extends StatelessWidget {
  const FolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Folio',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      builder: (context, child) => AppBackground(child: child!), // fundo do vidro
      home: const SplashScreen(),
    );
  }
}
```

---

## 8. Telas 0 e 1: splash, boas-vindas e permissão

### `lib/screens/splash_screen.dart`

No protótipo, a splash some sozinha em cerca de 1,8 s e um toque pula a espera. O `Timer` é cancelado no `dispose` para não navegar depois que a tela já saiu.

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:folio/core/theme.dart';
import 'package:folio/widgets/glass.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(const Duration(milliseconds: 1800), _leave);
  }

  void _leave() {
    _t?.cancel();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _leave,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            GlassBox(
              radius: 36,
              padding: const EdgeInsets.all(4),
              tint: const Color(0x1AFFFFFF),
              child: SvgPicture.asset('assets/folio-mark.svg', width: 112, height: 112),
            ),
            const SizedBox(height: 16),
            const Text('Folio', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Sua galeria, organizada', style: TextStyle(color: AppColors.muted)),
          ]),
        ),
      ),
    );
  }
}
```

> Nas aberturas seguintes, se a permissão já foi concedida, vale pular a boas-vindas: chame `requestPermission()` na splash e navegue direto para `ScanScreen` quando devolver `true`.

### `lib/screens/welcome_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:folio/core/theme.dart';
import 'package:folio/state/gallery_controller.dart';
import 'package:folio/widgets/glass.dart';
import 'package:folio/widgets/primary_button.dart';
import 'scan_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _allow(BuildContext context) async {
    final ok = await context.read<GalleryController>().requestPermission();
    if (!context.mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ScanScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sem acesso às fotos, o Folio não consegue listar as pastas'),
          action: SnackBarAction(label: 'Ajustes', onPressed: PhotoManager.openSetting),
        ),
      );
    }
  }

  void _notNow(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sem acesso às fotos, o Folio não consegue listar as pastas')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bullets = [
      'Encontra todas as pastas com imagens',
      'Mostra quantas imagens há em cada uma',
      'Não apaga nem move nada sem você pedir',
    ];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                GlassBox(
                  radius: 12,
                  padding: const EdgeInsets.all(2),
                  child: SvgPicture.asset('assets/folio-mark.svg', width: 32, height: 32),
                ),
                const SizedBox(width: 10),
                const Text('Folio', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ]),
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
              const SizedBox(height: 18),
              for (final t in bullets)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(children: [
                    const Icon(Icons.check, size: 20, color: AppColors.accent),
                    const SizedBox(width: 10),
                    Expanded(child: Text(t)),
                  ]),
                ),
              const SizedBox(height: 12),
              PrimaryButton(label: 'Permitir acesso às fotos', onPressed: () => _allow(context)),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () => _notNow(context),
                  child: const Text('Agora não', style: TextStyle(color: AppColors.muted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Teste: ao tocar em "Permitir", o Android mostra o diálogo de permissão. Se você negar, aparece o aviso com o atalho para os ajustes. "Agora não" só mostra o aviso e mantém a tela. O mosaico de capas do protótipo é enfeite e fica de fora da v1.

---

## 9. Tela 2: leitura das imagens

No app real, a "leitura" é o `scan()` do controller. O progresso vem do callback `onProgress`, uma pasta por vez.

### `lib/screens/scan_screen.dart`

```dart
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:folio/core/format.dart';
import 'package:folio/core/theme.dart';
import 'package:folio/state/gallery_controller.dart';
import 'package:folio/widgets/primary_button.dart';
import 'folders_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  ScanProgress? _p;
  bool _done = false;
  final _rows = <ScanProgress>[];

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    await context.read<GalleryController>().scan(onProgress: (p) {
      if (!mounted) return;
      setState(() {
        _p = p;
        _rows.add(p);
      });
    });
    if (!mounted) return;
    context.read<GalleryController>().watchGallery(); // passa a observar mudanças
    setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    final p = _p;
    final pct = p == null ? 0.0 : p.done / p.total;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Lendo seu celular',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.accent)),
              const SizedBox(height: 8),
              Text(fmt(p?.images ?? 0),
                  style: const TextStyle(
                    fontSize: 64, height: 1, fontWeight: FontWeight.w800, letterSpacing: -2.5,
                    fontFeatures: [FontFeature.tabularFigures()],
                  )),
              const SizedBox(height: 8),
              const Text('imagens encontradas', style: TextStyle(fontSize: 16, color: AppColors.muted)),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 8,
                  backgroundColor: const Color(0xFF27272D),
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 8),
              Text('${(pct * 100).round()}% concluído',
                  style: const TextStyle(fontSize: 13, color: AppColors.muted)),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: ListView.separated(
                    itemCount: _rows.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFF27272D)),
                    itemBuilder: (_, i) => SizedBox(
                      height: 50,
                      child: Row(children: [
                        const Icon(Icons.check, size: 22, color: AppColors.accent),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_rows[i].current,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                      ]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: _done ? 'Ver pastas encontradas' : 'Lendo…',
                onPressed: _done
                    ? () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const FoldersScreen()),
                        )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 10. Tela 3: lista de pastas

A primeira "pasta" da lista é sempre **Favoritas**. Ela não existe no sistema: é uma pasta virtual que reúne as favoritas de todos os álbuns (os ids guardados no controller). As outras vêm dos álbuns reais.

### `lib/widgets/folder_card.dart`

`AssetEntityImage` carrega e guarda em cache a miniatura. Peça sempre um tamanho pequeno (`ThumbnailSize.square(200)`), nunca a imagem original.

O card não recebe um `FolderInfo`, e sim os dados soltos (`name`, `count`, `covers`). Assim o mesmo card serve para as pastas reais e para Favoritas.

```dart
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:folio/core/format.dart';
import 'package:folio/core/theme.dart';
import 'package:folio/widgets/glass.dart';

class FolderCard extends StatelessWidget {
  const FolderCard({
    super.key,
    required this.name,
    required this.count,
    required this.covers,
    required this.onTap,
    this.isFavorites = false,
  });
  final String name;
  final int count;
  final List<AssetEntity> covers; // até 4 imagens
  final VoidCallback onTap;
  final bool isFavorites;

  @override
  Widget build(BuildContext context) {
    // Cada pasta é um cartão de vidro; a capa em mosaico fica dentro dele.
    return GestureDetector(
      onTap: onTap,
      child: GlassBox(
        radius: 28,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(fit: StackFit.expand, children: [
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: List.generate(4, (i) {
                    if (i >= covers.length) return Container(color: AppColors.surface);
                    return AssetEntityImage(
                      covers[i],
                      isOriginal: false,
                      thumbnailSize: const ThumbnailSize.square(200),
                      fit: BoxFit.cover,
                    );
                  }),
                ),
                if (isFavorites && covers.isEmpty)
                  const Center(child: Icon(Icons.favorite, size: 36, color: AppColors.accent)),
                if (isFavorites)
                  const Positioned(
                    left: 8,
                    bottom: 8,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Color(0x99141416),
                      child: Icon(Icons.favorite, size: 16, color: AppColors.accent),
                    ),
                  ),
              ]),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('${fmt(count)} imagens',
                style: const TextStyle(fontSize: 14, color: AppColors.muted)),
          ),
        ],
      ),
      ),
    );
  }
}
```

### `lib/screens/folders_screen.dart`

Aqui aparece o lado Material 3: um `SegmentedButton` (botão segmentado, com check no item ativo) no lugar dos chips de ordenação, e os cards de pasta em vidro.

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:folio/core/format.dart';
import 'package:folio/core/theme.dart';
import 'package:folio/state/gallery_controller.dart';
import 'package:folio/widgets/folder_card.dart';
import 'folder_screen.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});
  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  bool _searching = false;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<GalleryController>();
    final folders = c.visibleFolders;
    final q = c.query.trim().toLowerCase();
    final showFav = q.isEmpty || 'favoritas'.contains(q); // Favoritas sempre em primeiro
    final offset = showFav ? 1 : 0;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 8, 0),
              child: Row(children: [
                const Expanded(
                  child: Text('Pastas',
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1.2)),
                ),
                IconButton(
                  tooltip: 'Buscar pasta',
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() => _searching = !_searching);
                    if (!_searching) c.setQuery('');
                  },
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 2, 24, 0),
              child: Text('${fmt(c.totalImages)} imagens · ${c.folders.length} pastas',
                  style: const TextStyle(fontSize: 15, color: AppColors.muted)),
            ),
            if (_searching)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: TextField(
                  autofocus: true,
                  onChanged: c.setQuery,
                  decoration: InputDecoration(
                    hintText: 'Buscar pasta',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
              child: SegmentedButton<FolderSort>(
                expandedInsets: EdgeInsets.zero, // ocupa a largura toda
                segments: const [
                  ButtonSegment(value: FolderSort.count, label: Text('Mais imagens')),
                  ButtonSegment(value: FolderSort.name, label: Text('A–Z')),
                  ButtonSegment(value: FolderSort.recent, label: Text('Recentes')),
                ],
                selected: {c.sort},
                onSelectionChanged: (s) => c.setSort(s.first),
                style: SegmentedButton.styleFrom(
                  backgroundColor: const Color(0x12FFFFFF), // vidro
                  foregroundColor: AppColors.muted,
                  selectedBackgroundColor: AppColors.secContainer,
                  selectedForegroundColor: AppColors.onSecContainer,
                  side: const BorderSide(color: AppColors.line),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Expanded(
              child: folders.isEmpty && !showFav
                  ? const Center(child: Text('Nenhuma pasta encontrada.', style: TextStyle(color: AppColors.muted)))
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.80,
                      ),
                      itemCount: folders.length + offset,
                      itemBuilder: (_, i) {
                        if (showFav && i == 0) {
                          return FolderCard(
                            name: 'Favoritas',
                            count: c.favoritesCount,
                            covers: c.favCovers,
                            isFavorites: true,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const FolderScreen()), // sem pasta = Favoritas
                            ),
                          );
                        }
                        final f = folders[i - offset];
                        return FolderCard(
                          name: f.name,
                          count: f.count,
                          covers: f.covers,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => FolderScreen(folder: f)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
```

A sintaxe `for (final (s, label) in const [...])` usa *records* e exige Dart 3. Se o seu projeto for mais antigo, troque por uma lista de `MapEntry`.

Para a pasta Favoritas ficar atualizada, o controller recalcula `favCovers` e `favoritesCount` a cada favorito marcado (seção 7).

---

## 11. Tela 4: dentro da pasta

Uma pasta pode ter milhares de imagens, então **nunca** carregue tudo de uma vez. O código pagina de 90 em 90 conforme você rola (`getAssetListPaged`).

O que a tela faz:

- **Grade:** 3 colunas com 4 px entre as imagens e cantos arredondados (12). Só as barras flutuantes usam vidro; as miniaturas não, para a rolagem continuar leve.
- **Seleção:** segurar uma imagem entra no modo de seleção. O menu "⋮" também tem **Selecionar**, que entra no modo sem nenhuma imagem marcada. A barra flutuante embaixo traz **Favoritar** (adiciona todas, ou remove se todas já eram favoritas) e **Excluir**.
- **Ordem:** o menu "⋮" alterna entre "Mais recentes primeiro" e "Mais antigas primeiro".
- **Excluir com "Desfazer":** não há diálogo de confirmação. As imagens somem, e um aviso com **Desfazer** fica 5 s na tela (explicação na seção 13).
- **Favoritas:** a mesma tela serve para a pasta virtual. Quando `folder` é `null`, ela lista as favoritas de todos os álbuns.
- **Atualização:** a tela observa `revision` do controller e recarrega a lista quando a galeria muda.

### `lib/data/gallery_service.dart` (acrescente este método)

A ordem "mais antigas primeiro" exige pedir o álbum de novo com um filtro de ordenação crescente:

```dart
  /// Devolve o mesmo álbum, ordenado por data de criação.
  Future<AssetPathEntity> withOrder(AssetPathEntity path, {required bool newestFirst}) async {
    final filter = FilterOptionGroup()
      ..addOrderOption(OrderOption(type: OrderOptionType.createDate, asc: !newestFirst));
    return await path.fetchPathProperties(filterOptionGroup: filter) ?? path;
  }
```

Se o compilador reclamar dos nomes (`addOrderOption`, `fetchPathProperties`), confira no autocompletar: eles seguem a versão 3.x do `photo_manager`.

### `lib/screens/folder_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:provider/provider.dart';
import 'package:folio/core/format.dart';
import 'package:folio/core/theme.dart';
import 'package:folio/data/folder_info.dart';
import 'package:folio/state/gallery_controller.dart';
import 'package:folio/widgets/glass.dart';
import 'viewer_screen.dart';

class FolderScreen extends StatefulWidget {
  /// `folder == null` abre a pasta virtual "Favoritas".
  const FolderScreen({super.key, this.folder});
  final FolderInfo? folder;
  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  static const _pageSize = 90;
  final _scroll = ScrollController();
  final _assets = <AssetEntity>[];
  final _selected = <String>{};
  AssetPathEntity? _orderedPath;
  bool _selectMode = false;
  bool _newestFirst = true;
  bool _loading = false;
  bool _end = false;
  int _page = 0;
  late int _seenRevision;
  late int _seenFavRevision;

  bool get _isFavorites => widget.folder == null;

  /// Versão mais nova da pasta (contagem e álbum atualizados pelo controller).
  FolderInfo? get _folder {
    final f = widget.folder;
    if (f == null) return null;
    final all = context.read<GalleryController>().folders;
    return all.firstWhere((x) => x.id == f.id, orElse: () => f);
  }

  @override
  void initState() {
    super.initState();
    final c = context.read<GalleryController>();
    _seenRevision = c.revision;
    _seenFavRevision = c.favRevision;
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 600) _loadMore();
    });
    _reload();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Busca uma página. Devolve as imagens e se é a última.
  Future<(List<AssetEntity>, bool)> _fetch(int page) async {
    final c = context.read<GalleryController>();
    if (_isFavorites) {
      // Favoritas não têm paginação: vêm todas de uma vez.
      var all = await c.favoriteAssets();
      if (!_newestFirst) all = all.reversed.toList();
      return (all, true);
    }
    final path = _orderedPath ?? _folder!.path;
    final batch = await path.getAssetListPaged(page: page, size: _pageSize);
    // Esconde as que o usuário acabou de excluir (ainda dá para desfazer).
    return (batch.where((a) => !c.isPending(a.id)).toList(), batch.length < _pageSize);
  }

  Future<void> _loadMore() async {
    if (_loading || _end) return;
    _loading = true;
    final (batch, last) = await _fetch(_page);
    if (!mounted) return;
    setState(() {
      _assets.addAll(batch);
      _page++;
      _end = last;
      _loading = false;
    });
  }

  /// Recarrega do começo. Troca a lista só quando a nova chega,
  /// para a grade não piscar vazia.
  Future<void> _reload() async {
    if (!_isFavorites) {
      _orderedPath = await context
          .read<GalleryController>()
          .service
          .withOrder(_folder!.path, newestFirst: _newestFirst);
    }
    final (batch, last) = await _fetch(0);
    if (!mounted) return;
    setState(() {
      _assets
        ..clear()
        ..addAll(batch);
      _page = 1;
      _end = last;
      _loading = false;
    });
  }

  void _toggle(AssetEntity a) {
    setState(() => _selected.contains(a.id) ? _selected.remove(a.id) : _selected.add(a.id));
  }

  void _exitSelection() => setState(() {
        _selectMode = false;
        _selected.clear();
      });

  Future<void> _open(int index) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ViewerScreen(assets: List.of(_assets), initialIndex: index),
    ));
    if (mounted) _reload(); // reflete exclusões, cópias, edições e favoritos
  }

  Future<void> _favoriteSelected() async {
    final added = await context.read<GalleryController>().toggleFavorites(_selected.toList());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(added ? 'Adicionadas às favoritas' : 'Removidas das favoritas'),
    ));
    _exitSelection();
  }

  void _deleteSelected() {
    final ids = _selected.toList();
    setState(() {
      _assets.removeWhere((a) => ids.contains(a.id));
      _selected.clear();
      _selectMode = false;
    });
    context.read<GalleryController>().deleteWithUndo(context, ids);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<GalleryController>();

    // A galeria mudou (dentro ou fora do app), ou uma exclusão foi desfeita.
    if (c.revision != _seenRevision || (_isFavorites && c.favRevision != _seenFavRevision)) {
      _seenRevision = c.revision;
      _seenFavRevision = c.favRevision;
      _selected.clear(); // os ids marcados podem não existir mais
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _reload();
      });
    }

    final count = _isFavorites ? c.favoritesCount : _folder!.count;
    return PopScope(
      // O botão voltar do Android sai da seleção antes de sair da tela.
      canPop: !_selectMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exitSelection();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: _selectMode
              ? IconButton(icon: const Icon(Icons.close), onPressed: _exitSelection)
              : null,
          title: _selectMode
              ? Text(_selected.isEmpty
                  ? 'Selecionar itens'
                  : '${_selected.length} ${_selected.length > 1 ? 'selecionadas' : 'selecionada'}')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_isFavorites ? 'Favoritas' : _folder!.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    Text('${fmt(count)} imagens',
                        style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                  ],
                ),
          actions: [
            if (!_selectMode)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                color: AppColors.surface2,
                onSelected: (v) {
                  if (v == 'select') setState(() => _selectMode = true);
                  if (v == 'order') {
                    _newestFirst = !_newestFirst;
                    _reload();
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'select', child: Text('Selecionar')),
                  PopupMenuItem(
                    value: 'order',
                    child: Text(_newestFirst ? 'Mais antigas primeiro' : 'Mais recentes primeiro'),
                  ),
                ],
              ),
          ],
        ),
        body: Stack(children: [
          _assets.isEmpty && _end
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      _isFavorites
                          ? 'Toque no coração de uma imagem para ela aparecer aqui.'
                          : 'Esta pasta está vazia.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ),
                )
              : GridView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 96), // espaço para a barra flutuante
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: _assets.length,
                  itemBuilder: (_, i) {
                    final a = _assets[i];
                    final sel = _selected.contains(a.id);
                    return GestureDetector(
                      onTap: () => _selectMode ? _toggle(a) : _open(i),
                      onLongPress: () {
                        setState(() => _selectMode = true);
                        _toggle(a);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(fit: StackFit.expand, children: [
                        AssetEntityImage(
                          a,
                          isOriginal: false,
                          thumbnailSize: const ThumbnailSize.square(250),
                          fit: BoxFit.cover,
                        ),
                        if (sel) Container(color: Colors.black45),
                        if (_selectMode)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: sel ? AppColors.accent : Colors.black38,
                              child: sel
                                  ? const Icon(Icons.check, size: 16, color: AppColors.onAccent)
                                  : null,
                            ),
                          ),
                        if (c.isFavorite(a.id))
                          const Positioned(
                            right: 6,
                            bottom: 6,
                            child: Icon(Icons.favorite, size: 18, color: AppColors.accent),
                          ),
                      ]),
                      ),
                    );
                  },
                ),
          if (_selectMode)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: GlassBar(
                  child: Row(children: [
                    BarAction(Icons.favorite_border, 'Favoritar',
                        _selected.isEmpty ? null : _favoriteSelected),
                    BarAction(Icons.delete_outline, 'Excluir',
                        _selected.isEmpty ? null : _deleteSelected,
                        color: AppColors.danger),
                  ]),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
```

O `PopScope` com `onPopInvokedWithResult` exige Flutter 3.24 ou mais novo. Em versões anteriores use `onPopInvoked`.

---

## 12. Tela 5: visualizador

O visualizador ocupa a **tela inteira**: a barra do topo (com um degradê escuro) e a barra de ações (vidro fosco) flutuam sobre a imagem. Ele usa:

- `PageView`: deslizar entre imagens.
- `InteractiveViewer`: zoom com pinça e arrastar quando ampliada.
- **Toque duplo:** amplia 2,5× no ponto tocado, e outro toque duplo volta ao normal.
- **Travar o deslize quando ampliada:** senão o arrasto para mover a imagem trocaria de página. O `PageView` usa `NeverScrollableScrollPhysics` enquanto há zoom.

Para economizar memória, carregue uma versão grande (1600 px), não o arquivo original. Se quiser o original, troque por `isOriginal: true`.

### `lib/screens/viewer_screen.dart`

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:folio/core/format.dart';
import 'package:folio/core/theme.dart';
import 'package:folio/data/folder_info.dart';
import 'package:folio/state/gallery_controller.dart';
import 'package:folio/widgets/glass.dart';
import 'editor_screen.dart';

class ViewerScreen extends StatefulWidget {
  const ViewerScreen({super.key, required this.assets, required this.initialIndex});
  final List<AssetEntity> assets;
  final int initialIndex;
  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  late final PageController _page = PageController(initialPage: widget.initialIndex);
  late final List<AssetEntity> _assets = List.of(widget.assets);
  late int _index = widget.initialIndex;
  Timer? _slide;
  bool _zoomed = false;

  AssetEntity get _cur => _assets[_index];

  @override
  void dispose() {
    _slide?.cancel();
    _page.dispose();
    super.dispose();
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ---------- slideshow ----------
  void _startSlide() {
    _slide?.cancel();
    _slide = Timer.periodic(const Duration(milliseconds: 2200), (_) {
      final next = (_index + 1) % _assets.length;
      _page.animateToPage(next,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
    setState(() {});
  }

  void _stopSlide() {
    _slide?.cancel();
    setState(() => _slide = null);
  }

  // ---------- ações ----------
  Future<void> _share() async {
    final file = await _cur.file;
    if (file == null) return;
    await Share.shareXFiles([XFile(file.path)]);
  }

  /// Sem diálogo: a imagem some e o aviso mostra "Desfazer" (veja o controller).
  void _delete() {
    final id = _cur.id;
    final c = context.read<GalleryController>();
    setState(() {
      _assets.removeAt(_index);
      if (_index >= _assets.length) _index = _assets.length - 1;
    });
    c.deleteWithUndo(context, [id]);
    if (_assets.isEmpty) Navigator.pop(context);
  }

  Future<void> _edit() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EditorScreen(asset: _cur)),
    );
    if (!mounted) return;
    if (saved == true) {
      _toast('Cópia salva na galeria');
      context.read<GalleryController>().refresh();
    }
  }

  Future<void> _info() async {
    final a = _cur;
    final title = await a.titleAsync;
    final file = await a.originFile;
    final bytes = await file?.length() ?? 0;
    if (!mounted) return;
    final rows = <(String, String)>[
      ('Nome', title),
      ('Caminho', a.relativePath ?? '—'), // só no Android
      ('Tamanho', sizeLabel(bytes)),
      ('Resolução',
          '${a.width} × ${a.height} (${(a.width * a.height / 1e6).toStringAsFixed(1).replaceAll('.', ',')} MP)'),
      ('Última modificação', fullDate(a.modifiedDateTime)),
      ('Data de criação', fullDate(a.createDateTime)),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface2,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Informações', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(width: 120, child: Text(r.$1, style: const TextStyle(fontWeight: FontWeight.w700))),
                Expanded(child: Text(r.$2, style: const TextStyle(color: AppColors.muted))),
              ]),
            ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ),
        ]),
      ),
    );
  }

  Future<void> _more() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface2,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.play_arrow_outlined),
            title: const Text('Slideshow'),
            onTap: () { Navigator.pop(context); _startSlide(); },
          ),
          ListTile(
            leading: const Icon(Icons.copy_outlined),
            title: const Text('Copiar para'),
            onTap: () { Navigator.pop(context); _pickFolder(move: false); },
          ),
          ListTile(
            leading: const Icon(Icons.drive_file_move_outline),
            title: const Text('Mover para'),
            onTap: () { Navigator.pop(context); _pickFolder(move: true); },
          ),
        ]),
      ),
    );
  }

  Future<void> _pickFolder({required bool move}) async {
    final c = context.read<GalleryController>();
    final targets = c.folders.where((f) => !f.path.isAll).toList();
    final FolderInfo? chosen = await showModalBottomSheet<FolderInfo>(
      context: context,
      backgroundColor: AppColors.surface2,
      builder: (_) => SafeArea(
        child: ListView(shrinkWrap: true, children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(move ? 'Mover para' : 'Copiar para',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          ),
          for (final f in targets)
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(f.name),
              trailing: Text(fmt(f.count), style: const TextStyle(color: AppColors.muted)),
              onTap: () => Navigator.pop(context, f),
            ),
        ]),
      ),
    );
    if (chosen == null || !mounted) return;

    if (move) {
      final ok = await c.service.moveTo(_cur, chosen.path);
      if (!ok || !mounted) return _toast('Não foi possível mover');
      setState(() {
        _assets.removeAt(_index);
        if (_index >= _assets.length) _index = _assets.length - 1;
      });
      if (_assets.isEmpty) return Navigator.pop(context);
      _toast('Movida para ${chosen.name}');
    } else {
      final copy = await c.service.copyTo(_cur, chosen.path);
      _toast(copy == null ? 'Não foi possível copiar' : 'Copiada para ${chosen.name}');
    }
    c.refresh();
  }

  // ---------- tela ----------
  @override
  Widget build(BuildContext context) {
    final fav = context.watch<GalleryController>();
    final isFav = fav.isFavorite(_cur.id);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      extendBodyBehindAppBar: true, // a imagem ocupa a tela toda
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xCC0A0A0B), Color(0x000A0A0B)],
            ),
          ),
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(dayLabel(_cur.createDateTime),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Text('${_index + 1} de ${_assets.length}',
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ]),
        actions: [
          IconButton(
            tooltip: 'Favoritar',
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? AppColors.accent : null),
            onPressed: () => fav.toggleFavorite(_cur.id),
          ),
          IconButton(tooltip: 'Informações', icon: const Icon(Icons.info_outline), onPressed: _info),
        ],
      ),
      body: Stack(children: [
        PageView.builder(
          controller: _page,
          itemCount: _assets.length,
          // Com zoom, o arrasto move a imagem em vez de trocar de página.
          physics: _zoomed ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
          onPageChanged: (i) => setState(() {
            _index = i;
            _zoomed = false;
          }),
          itemBuilder: (_, i) => _ZoomableImage(
            key: ValueKey(_assets[i].id), // cada página guarda o próprio zoom
            asset: _assets[i],
            onZoomChanged: (z) {
              if (z != _zoomed) setState(() => _zoomed = z);
            },
          ),
        ),
        if (_slide != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 64,
            left: 0,
            right: 0,
            child: Center(
              child: FilledButton(onPressed: _stopSlide, child: const Text('Parar slideshow')),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: GlassBar(
              child: Row(children: [
                BarAction(Icons.ios_share, 'Compartilhar', _share),
                BarAction(Icons.delete_outline, 'Excluir', _delete, color: AppColors.danger),
                BarAction(Icons.auto_fix_high, 'Editar', _edit),
                BarAction(Icons.more_vert, 'Mais', _more),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

/// Uma imagem com zoom (pinça), arrastar e toque duplo.
class _ZoomableImage extends StatefulWidget {
  const _ZoomableImage({super.key, required this.asset, required this.onZoomChanged});
  final AssetEntity asset;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final _tc = TransformationController();
  Offset _tap = Offset.zero;

  bool get _isZoomed => _tc.value.getMaxScaleOnAxis() > 1.01;

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  void _toggleZoom() {
    if (_isZoomed) {
      _tc.value = Matrix4.identity();
    } else {
      // Amplia 2,5x mantendo o ponto tocado no mesmo lugar da tela.
      const s = 2.5;
      _tc.value = Matrix4.diagonal3Values(s, s, 1)
        ..setTranslationRaw(-_tap.dx * (s - 1), -_tap.dy * (s - 1), 0);
    }
    widget.onZoomChanged(_isZoomed);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (d) => _tap = d.localPosition,
      onDoubleTap: _toggleZoom,
      child: InteractiveViewer(
        transformationController: _tc,
        minScale: 1,
        maxScale: 5,
        onInteractionEnd: (_) => widget.onZoomChanged(_isZoomed),
        child: SizedBox.expand(
          child: AssetEntityImage(
            widget.asset,
            isOriginal: false,
            thumbnailSize: const ThumbnailSize(1600, 1600),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
```

Quando você abre uma imagem pela pasta **Favoritas** e tira o coração, ela continua na tela até você voltar. Ao voltar, a lista de Favoritas já está atualizada (o controller sobe `favRevision`).

---

## 13. Ações do visualizador: o que cada uma faz de verdade

| Ação | Como é feita | Observação |
|---|---|---|
| Favoritar | `GalleryController.toggleFavorite` | Fica só no app. Se desinstalar, perde. As favoritas de todas as pastas aparecem na pasta virtual **Favoritas**. |
| Excluir | `GalleryController.deleteWithUndo` e, no fim, `PhotoManager.editor.deleteWithIds` | Sem diálogo próprio: a imagem some e o aviso mostra **Desfazer** por 5 s. A exclusão de verdade só acontece quando o aviso fecha. No Android 11+ o sistema mostra a confirmação dele nesse momento. Se o usuário negar, a imagem volta. |
| Zoom | `InteractiveViewer` + toque duplo | Pinça, arrastar quando ampliada e toque duplo (2,5×). O deslize entre imagens fica travado enquanto há zoom. |
| Copiar para | `copyAssetToPath`; plano B: `saveImage` com `relativePath` | O código tenta `copyAssetToPath` primeiro e, se falhar, regrava os bytes. |
| Mover para | Android ≤ 10: `moveAssetToAnother`. Android 11+: copiar e depois excluir | A documentação diz que o move direto não funciona no Android 11+. |
| Compartilhar | `share_plus` | Em versões novas do `share_plus` a API mudou (`SharePlus.instance.share`). Siga o exemplo da versão que você instalou. |
| Info | Propriedades de `AssetEntity` | `relativePath` só existe no Android. |
| Slideshow | `Timer.periodic` (2,2 s) + `PageController` | Volta à primeira depois da última. Cancele o timer no `dispose`. |

#### Como funciona o "Desfazer"

O app não move a imagem para uma lixeira própria. Ele só **adia** a exclusão:

1. O usuário exclui. O id entra em `_pending` e as telas passam a esconder essa imagem.
2. O `SnackBar` com **Desfazer** fica 5 s na tela.
3. Se o usuário toca em Desfazer, o id sai de `_pending` e a imagem volta. Nada foi apagado do aparelho.
4. Se o aviso fecha sozinho, o app chama `deleteWithIds`. É aqui que o Android 11+ mostra o diálogo do sistema.

Se o app for fechado durante os 5 s, a exclusão simplesmente não acontece. É o lado seguro da escolha. Quem prefere a lixeira do sistema pode usar `PhotoManager.editor.android.moveToTrash` (Android 11+), mas ela não oferece um "Desfazer" dentro do app.

Fora da v1 (no protótipo eram só avisos): **Renomear**, **Bloquear**, **Abrir com**, **Imprimir**, **Definir como**. Renomear no Android 11+ precisa de código nativo com consentimento do usuário (MediaStore).

---

## 14. Tela 6: editor de imagem

O caminho mais rápido é o pacote `pro_image_editor`, que já traz cortar, girar, espelhar, filtros, ajustes (brilho, contraste, saturação), pincel, texto e desfoque, com visual pronto. O Apêndice A mostra como fazer um editor próprio igual ao do protótipo, caso queira controle total do visual.

### `lib/screens/editor_screen.dart`

```dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key, required this.asset});
  final AssetEntity asset;
  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    widget.asset.originBytes.then((b) {
      if (mounted) setState(() => _bytes = b);
    });
  }

  /// Salva uma CÓPIA na mesma pasta da original.
  Future<void> _save(Uint8List edited) async {
    final title = await widget.asset.titleAsync;
    final base = title.contains('.') ? title.substring(0, title.lastIndexOf('.')) : title;
    await PhotoManager.editor.saveImage(
      edited, // JPG por padrão
      filename: '${base}_editada.jpg',
      title: '${base}_editada.jpg',
      relativePath: widget.asset.relativePath ?? 'Pictures/Folio',
    );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    if (bytes == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return ProImageEditor.memory(
      bytes,
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: _save,
      ),
    );
  }
}
```

Pontos de atenção:

- O exemplo oficial do pacote usa `ProImageEditor.network` com o callback `onImageEditingComplete`. O construtor `.memory` segue a mesma ideia. Confira a assinatura exata na documentação da versão instalada.
- O pacote pede a imagem em bytes. `originBytes` carrega o arquivo inteiro; em fotos muito grandes, considere reduzir antes.
- Para o tema escuro igual ao app, use as configurações do editor (`configs`). A página do pacote lista as opções de tema.
- Salvar como **cópia** é a escolha mais segura. Sobrescrever o original exige permissões extras.

---

## 15. Rodar, testar e publicar

### Rodar

```bash
flutter pub get
flutter run          # com o celular conectado por USB
```

### Roteiro de testes no aparelho

| # | Teste | Esperado |
|---|---|---|
| 1 | Abrir o app pela primeira vez | Splash por ~2 s (toque pula) e depois boas-vindas |
| 2 | Tocar em "Permitir" e aceitar | Leitura com contagem subindo |
| 3 | Negar a permissão ou tocar em "Agora não" | Aviso (com atalho para Ajustes ao negar) |
| 4 | Conferir as pastas | Mesmos nomes e contagens do app de galeria do celular |
| 5 | Ordenar e buscar | A lista muda na hora |
| 6 | Abrir uma pasta grande e rolar | Mais imagens aparecem sem travar |
| 7 | Segurar uma imagem | Entra em seleção; favoritar marca todas; excluir mostra o aviso com Desfazer |
| 8 | Abrir uma imagem, deslizar, dar zoom | Troca de imagem; pinça e toque duplo funcionam; com zoom, arrastar move a imagem sem trocar de página |
| 9 | Favoritar, fechar e abrir o app | Favorito continua |
| 10 | Editar e salvar | Cópia `..._editada.jpg` aparece na mesma pasta |
| 11 | Copiar e mover para outra pasta | A pasta de destino ganha a imagem |
| 12 | Testar em Android 13/14 (acesso parcial) | O app mostra só o que foi liberado |
| 13 | Excluir uma imagem e tocar em Desfazer | A imagem volta no mesmo lugar e nada foi apagado do aparelho |
| 14 | Excluir e deixar o aviso fechar | No Android 11+ aparece o diálogo do sistema; ao confirmar, a imagem some de vez |
| 15 | Abrir Favoritas e tirar um coração | Ao voltar, a imagem sai da lista |
| 16 | Menu ⋮ da pasta: Mais antigas primeiro | A ordem da grade inverte |

Teste em pelo menos duas versões de Android: uma com 10 ou menos e outra com 11 ou mais, porque excluir e mover se comportam de formas diferentes.

### Publicar

```bash
flutter build appbundle --release   # Google Play
```

A Google Play restringe as permissões de fotos e vídeos a apps cuja função principal precisa delas (galeria é um caso previsto). Você preenche uma declaração no Play Console ao publicar. Leia a política atual antes de enviar.

---

## 16. Armadilhas comuns

| Sintoma | Causa provável | Solução |
|---|---|---|
| Lista de pastas vazia | Permissão negada ou só parcial | Ver o estado (`requestPermissionExtend`) e abrir Ajustes |
| Crash ou lentidão na grade | Carregando original em vez de miniatura | Sempre `isOriginal: false` com `ThumbnailSize` pequeno |
| Memória estourando no visualizador | Imagem original gigante | Limitar o `ThumbnailSize` (1600 px) |
| Pasta mostra número errado | Álbum "Recentes" somado junto | Contar o álbum `isAll` à parte (feito no controller) |
| `deleteWithIds` devolve lista vazia | Usuário negou o diálogo do sistema | Tratar como cancelamento, não como erro (o `deleteWithUndo` já faz a imagem voltar) |
| A imagem excluída reaparece logo depois | A tela recarregou e o id ainda existe no sistema | Filtrar com `isPending` ao carregar (já está no `_fetch`) |
| No zoom, arrastar troca de página | O `PageView` ainda aceita rolagem | `NeverScrollableScrollPhysics` enquanto `_zoomed` |
| Vidro desfoca a tela toda | Faltou o `ClipRRect` em volta do `BackdropFilter` | Usar `GlassBox` e `GlassBar` como estão |
| O vidro parece um retângulo cinza liso | Não há nada colorido atrás para desfocar | Conferir se o `AppBackground` está no `builder` do `MaterialApp` e se o `Scaffold` é transparente |
| Rolagem pesada com vidro | Muitos `BackdropFilter` ao mesmo tempo | Usar vidro só em barras e cards, nunca em cada miniatura |
| Mover não funciona no Android 11+ | Limite do sistema | Copiar e excluir (já está no `moveTo`) |
| Favoritos somem | Sem persistência | `shared_preferences` (já está no controller) |
| Erro de nome de parâmetro | Versão do pacote diferente | Conferir a assinatura no autocompletar |
| Lista não atualiza após mudanças fora do app | Sem observador | `watchGallery()` e `didChangeAppLifecycleState` no controller (seção 7) |
| App relê tudo várias vezes seguidas | Aviso do sistema chega em rajada | Debounce no `refresh()` (já está no controller) |

---

## 17. Evoluções

1. **Vídeos:** troque `RequestType.image` por `RequestType.common` e mostre a duração (`asset.videoDuration`) como no protótipo.
2. **Lixeira de verdade:** hoje o "Desfazer" dura 5 s. Para uma lixeira que guarda por dias, use `PhotoManager.editor.android.moveToTrash(...)` (Android 11+) e uma tela que lista a lixeira do sistema.
3. **Fixar pastas no topo:** toque longo no card da pasta guarda o id em `shared_preferences` (como os favoritos) e o `visibleFolders` coloca as fixadas primeiro, logo depois de Favoritas.
4. **Agrupar a grade por dia** ("Hoje", "Ontem", "03/11"): troque o `GridView` por um `CustomScrollView` com um `SliverToBoxAdapter` de título e um `SliverGrid` para cada dia. Ajuda muito em pastas grandes.
5. **Pinça para mudar as colunas da grade** (de 1 a 5): guarde o número de colunas no estado e troque o `crossAxisCount`. Cuidado: a pinça disputa o gesto com a rolagem, então teste bem.
6. **Mais ferramentas do protótipo:** Bloquear (pasta protegida com biometria), Imprimir (pacote `printing`), Definir como papel de parede (pacote específico), Abrir com (pacote de abrir arquivos). Veja a documentação de cada um antes de adotar.
7. **Cache dos totais:** guarde os resultados do `scan()` (por exemplo com Isar ou Drift) para abrir o app mais rápido. Com muitas favoritas, guarde também a data de cada uma: hoje `favoriteAssets()` busca uma por uma para ordenar.
8. **Acesso parcial (Android 14 / iOS):** mostre um aviso "Você liberou só algumas fotos" com botão para `PhotoManager.openSetting()`.

---

## Apêndice A: editor próprio (sem `pro_image_editor`)

Use este caminho se quiser o mesmo visual do protótipo (abas Cortar, Filtros, Ajustes, Desenhar, Texto).

### A.1 Ideia geral

Mantenha um objeto de estado e redesenhe a imagem a cada mudança:

```dart
class EditState {
  int quarterTurns = 0;        // girar 90°
  bool flipH = false;          // espelhar
  double? aspect;              // proporção do corte (null = original)
  int filterIndex = 0;
  double brightness = 0;       // -1..1
  double contrast = 0;         // -1..1
  double saturation = 0;       // -1..1
  double warmth = 0;           // -1..1
  double blur = 0;             // 0..1
  final strokes = <Stroke>[];  // desenho
  final texts = <TextItem>[];  // textos
}
```

A imagem é mostrada com `RotatedBox`, `Transform.flip` e `ColorFiltered`. O desenho e os textos ficam numa camada `CustomPaint` por cima.

### A.2 Filtros e ajustes com `ColorFilter.matrix`

Cada filtro é uma matriz 4×5 (20 números). Ajustes e filtro se combinam multiplicando as matrizes.

```dart
const identity = <double>[
  1, 0, 0, 0, 0,
  0, 1, 0, 0, 0,
  0, 0, 1, 0, 0,
  0, 0, 0, 1, 0,
];

const grayscale = <double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
];

const sepia = <double>[
  0.393, 0.769, 0.189, 0, 0,
  0.349, 0.686, 0.168, 0, 0,
  0.272, 0.534, 0.131, 0, 0,
  0, 0, 0, 1, 0,
];

/// s = 1 é normal; 0 = preto e branco; 2 = bem saturado
List<double> saturationMatrix(double s) {
  const lr = 0.2126, lg = 0.7152, lb = 0.0722;
  final sr = (1 - s) * lr, sg = (1 - s) * lg, sb = (1 - s) * lb;
  return [
    sr + s, sg, sb, 0, 0,
    sr, sg + s, sb, 0, 0,
    sr, sg, sb + s, 0, 0,
    0, 0, 0, 1, 0,
  ];
}

/// c = 1 é normal
List<double> contrastMatrix(double c) {
  final t = (1 - c) / 2 * 255;
  return [
    c, 0, 0, 0, t,
    0, c, 0, 0, t,
    0, 0, c, 0, t,
    0, 0, 0, 1, 0,
  ];
}

/// b em -1..1
List<double> brightnessMatrix(double b) {
  final o = b * 255;
  return [
    1, 0, 0, 0, o,
    0, 1, 0, 0, o,
    0, 0, 1, 0, o,
    0, 0, 0, 1, 0,
  ];
}

/// Aplica `b` primeiro e `a` depois.
List<double> mul(List<double> a, List<double> b) {
  final r = List<double>.filled(20, 0);
  for (var row = 0; row < 4; row++) {
    for (var col = 0; col < 5; col++) {
      var v = 0.0;
      for (var k = 0; k < 4; k++) {
        v += a[row * 5 + k] * b[k * 5 + col];
      }
      if (col == 4) v += a[row * 5 + 4];
      r[row * 5 + col] = v;
    }
  }
  return r;
}
```

Montando tudo:

```dart
ColorFilter buildFilter(EditState e, List<List<double>> presets) {
  var m = presets[e.filterIndex];
  m = mul(brightnessMatrix(e.brightness), m);
  m = mul(contrastMatrix(1 + e.contrast), m);
  m = mul(saturationMatrix(1 + e.saturation), m);
  m = mul(warmthMatrix(e.warmth), m);
  return ColorFilter.matrix(m);
}
```

O protótipo também tem o ajuste **Calor** (de -100 a 100). Em matriz, calor é somar vermelho e tirar azul (ou o contrário):

```dart
/// w em -1..1 (positivo = mais quente)
List<double> warmthMatrix(double w) {
  final o = w * 25;
  return [
    1, 0, 0, 0, o,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, -o,
    0, 0, 0, 1, 0,
  ];
}
```

Inclua no `buildFilter` junto dos outros: `m = mul(warmthMatrix(e.warmth), m);`.

O ajuste **Desfoque** não é matriz de cor. Aplique com `ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: s, sigmaY: s), child: ...)`, em que `s` vai de 0 a cerca de 8 conforme o controle (0 a 100).

Presets do protótipo e como aproximá-los (os valores são ponto de partida, ajuste a gosto):

| Preset | Matriz |
|---|---|
| Original | `identity` |
| Vívido | `mul(contrastMatrix(1.1), saturationMatrix(1.5))` |
| Quente | `mul(warmthMatrix(0.5), saturationMatrix(1.3))` |
| Frio | `mul(warmthMatrix(-0.5), brightnessMatrix(0.02))` |
| P&B | `mul(contrastMatrix(1.1), grayscale)` |
| Sépia | `sepia` |
| Fade | `mul(brightnessMatrix(0.05), contrastMatrix(0.85))` |
| Noir | `mul(contrastMatrix(1.4), grayscale)` |

### A.3 Cortar

Para um corte com bordas arrastáveis, use um pacote pronto (por exemplo `image_cropper` ou `crop_your_image`) e chame-o quando o usuário abrir a aba Cortar. O protótipo usa corte centralizado por proporção, que dá para fazer com `AspectRatio` + `ClipRect` + `FittedBox(fit: BoxFit.cover)`.

### A.4 Desenhar e texto

```dart
class Stroke {
  Stroke(this.color, this.width);
  final Color color;
  final double width;
  final points = <Offset>[]; // em coordenadas 0..1 (relativas ao tamanho da imagem)
}

class StrokePainter extends CustomPainter {
  StrokePainter(this.strokes);
  final List<Stroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = s.width * size.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final path = Path();
      for (var i = 0; i < s.points.length; i++) {
        final p = Offset(s.points[i].dx * size.width, s.points[i].dy * size.height);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(StrokePainter old) => true;
}
```

Guardar os pontos em coordenadas de 0 a 1 faz o desenho acompanhar a imagem em qualquer tamanho (preview e exportação). Use `GestureDetector` com `onPanStart/onPanUpdate` para preencher `points`. Textos funcionam igual: guarde posição relativa, cor e tamanho, e arraste com `onPanUpdate`.

### A.5 Exportar o resultado

Envolva imagem + filtro + camadas num `RepaintBoundary` e capture:

```dart
final key = GlobalKey();

// ... RepaintBoundary(key: key, child: <imagem editada>)

Future<Uint8List> export() async {
  final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 3);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}
```

O Flutter exporta PNG por esse caminho. Para salvar em JPG, converta com o pacote `image`, ou salve o PNG mesmo (`filename: '..._editada.png'`). Depois grave com `PhotoManager.editor.saveImage`, igual ao passo 14.

---

## Referências

- [Documentação do `photo_manager`](https://pub.dev/documentation/photo_manager/latest/): permissões, álbuns, paginação, `PhotoManager.editor`.
- [Pacote `pro_image_editor`](https://pub.dev/packages/pro_image_editor): recursos do editor e exemplo de uso.
