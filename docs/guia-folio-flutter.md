# Folio em Flutter: guia passo a passo

App de galeria que lê as imagens reais do celular, separa por pasta, abre cada imagem em um visualizador e tem editor. Este guia reproduz o protótipo `folio.html`, tela por tela.

**Sumário**

0. O que você vai construir
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
| Pastas (grade 2 colunas, ordenar, buscar) | `FoldersScreen` + `GalleryController` |
| Dentro da pasta (grade 3 colunas, selecionar, favoritar, excluir) | `FolderScreen` com paginação |
| Visualizador (deslizar, favoritar, info, menu Mais) | `ViewerScreen` com `PageView` + `InteractiveViewer` |
| Editor (cortar, filtros, ajustes, desenhar, texto) | `EditorScreen` com `pro_image_editor` |

A palavra-chave do app é **álbum**: no Android e no iOS, cada pasta de imagens aparece como um `AssetPathEntity`. O pacote `photo_manager` lista esses álbuns com a contagem de imagens, que é exatamente o que a tela "Pastas" precisa.

O que **não** dá para fazer do mesmo jeito que no protótipo, e como resolver:

| Recurso | Situação no Flutter |
|---|---|
| Favoritar | O `photo_manager` não documenta favoritar no Android. Guarde os favoritos no próprio app (`shared_preferences`). |
| Mover para outra pasta | `moveAssetToAnother` não funciona no Android 11+ (API 30+). Use copiar + excluir. |
| Renomear | Exige consentimento do sistema (MediaStore). Deixe fora da v1. |
| Bloquear, Abrir com, Definir como, Imprimir | Fora da v1 (no protótipo são só avisos "simulado"). Veja a seção 17. |

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
flutter pub add photo_manager photo_manager_image_provider provider shared_preferences pro_image_editor share_plus
```

| Pacote | Para quê |
|---|---|
| `photo_manager` | Ler álbuns e imagens, excluir, copiar, salvar |
| `photo_manager_image_provider` | Widget `AssetEntityImage` (miniaturas com cache) |
| `provider` | Estado simples com `ChangeNotifier` |
| `shared_preferences` | Guardar favoritos |
| `pro_image_editor` | Editor pronto: cortar, girar, filtros, ajustes, desenho, texto |
| `share_plus` | Compartilhar a imagem |

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

As mesmas cores do protótipo.

```dart
import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0F1115);
  static const surface = Color(0xFF1A1D24);
  static const surface2 = Color(0xFF23262D);
  static const line = Color(0xFF2A2F3A);
  static const text = Color(0xFFF2F4F7);
  static const muted = Color(0xFFA9B0BC);
  static const accent = Color(0xFF5EEAD4);
  static const onAccent = Color(0xFF04211D);
  static const danger = Color(0xFFFF9A94);
}

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      surface: AppColors.surface,
      error: AppColors.danger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
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
          shape: const StadiumBorder(),
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
import 'package:flutter/foundation.dart';
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

class GalleryController extends ChangeNotifier {
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
  }

  /// Chame depois de excluir, copiar, mover ou salvar.
  Future<void> refresh() => scan();

  // ---------- favoritos (guardados no app) ----------
  Future<void> loadFavorites() async {
    final p = await SharedPreferences.getInstance();
    _favorites = (p.getStringList(_favKey) ?? []).toSet();
    notifyListeners();
  }

  bool isFavorite(String assetId) => _favorites.contains(assetId);

  /// Favorita vários de uma vez (barra de seleção). Se todos já são
  /// favoritos, remove; senão, adiciona todos. Devolve true se adicionou.
  Future<bool> toggleFavorites(Iterable<String> ids) async {
    final add = !ids.every(_favorites.contains);
    add ? _favorites.addAll(ids) : _favorites.removeAll(ids);
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_favKey, _favorites.toList());
    return add;
  }

  Future<void> toggleFavorite(String assetId) async {
    _favorites.contains(assetId)
        ? _favorites.remove(assetId)
        : _favorites.add(assetId);
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_favKey, _favorites.toList());
  }
}
```

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

class FolioApp extends StatelessWidget {
  const FolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Folio',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
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
import 'package:folio/core/theme.dart';
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
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.folder_outlined, size: 40, color: AppColors.onAccent),
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
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:folio/core/theme.dart';
import 'package:folio/state/gallery_controller.dart';
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
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.folder_outlined, size: 20, color: AppColors.onAccent),
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
    if (mounted) setState(() => _done = true);
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
                  backgroundColor: const Color(0xFF262A33),
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
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFF262A33)),
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

### `lib/widgets/folder_card.dart`

`AssetEntityImage` carrega e guarda em cache a miniatura. Peça sempre um tamanho pequeno (`ThumbnailSize.square(200)`), nunca a imagem original.

```dart
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:folio/core/format.dart';
import 'package:folio/core/theme.dart';
import 'package:folio/data/folder_info.dart';

class FolderCard extends StatelessWidget {
  const FolderCard({super.key, required this.folder, required this.onTap});
  final FolderInfo folder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: List.generate(4, (i) {
                  if (i >= folder.covers.length) return Container(color: AppColors.surface);
                  return AssetEntityImage(
                    folder.covers[i],
                    isOriginal: false,
                    thumbnailSize: const ThumbnailSize.square(200),
                    fit: BoxFit.cover,
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(folder.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text('${fmt(folder.count)} imagens',
              style: const TextStyle(fontSize: 14, color: AppColors.muted)),
        ],
      ),
    );
  }
}
```

### `lib/screens/folders_screen.dart`

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
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.9)),
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
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
              child: Wrap(spacing: 8, children: [
                for (final (s, label) in const [
                  (FolderSort.count, 'Mais imagens'),
                  (FolderSort.name, 'A–Z'),
                  (FolderSort.recent, 'Recentes'),
                ])
                  ChoiceChip(
                    label: Text(label),
                    selected: c.sort == s,
                    onSelected: (_) => c.setSort(s),
                    selectedColor: AppColors.accent,
                    labelStyle: TextStyle(
                      color: c.sort == s ? AppColors.onAccent : AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: const StadiumBorder(side: BorderSide(color: AppColors.line)),
                  ),
              ]),
            ),
            Expanded(
              child: folders.isEmpty
                  ? const Center(child: Text('Nenhuma pasta encontrada.', style: TextStyle(color: AppColors.muted)))
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: folders.length,
                      itemBuilder: (_, i) => FolderCard(
                        folder: folders[i],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => FolderScreen(folder: folders[i])),
                        ),
                      ),
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

---

## 11. Tela 4: dentro da pasta

Uma pasta pode ter milhares de imagens, então **nunca** carregue tudo de uma vez. O código pagina de 90 em 90 conforme você rola (`getAssetListPaged`). Segurar uma imagem entra no modo de seleção; enquanto houver algo selecionado, tocar seleciona. Com itens selecionados, a barra mostra **Favoritar** (adiciona todas, ou remove se todas já eram favoritas) e **Excluir**.

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
import 'viewer_screen.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key, required this.folder});
  final FolderInfo folder;
  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  static const _pageSize = 90;
  final _scroll = ScrollController();
  final _assets = <AssetEntity>[];
  final _selected = <String>{};
  int _page = 0;
  bool _loading = false;
  bool _end = false;

  bool get _selecting => _selected.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 600) _loadMore();
    });
    _loadMore();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_loading || _end) return;
    _loading = true;
    final batch = await widget.folder.path.getAssetListPaged(page: _page, size: _pageSize);
    if (!mounted) return;
    setState(() {
      _assets.addAll(batch);
      _page++;
      _end = batch.length < _pageSize;
      _loading = false;
    });
  }

  Future<void> _reload() async {
    setState(() {
      _assets.clear();
      _page = 0;
      _end = false;
    });
    await _loadMore();
  }

  void _toggle(AssetEntity a) {
    setState(() => _selected.contains(a.id) ? _selected.remove(a.id) : _selected.add(a.id));
  }

  Future<void> _open(int index) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ViewerScreen(
        assets: List.of(_assets),
        initialIndex: index,
      ),
    ));
    if (mounted) _reload(); // reflete exclusões, cópias e edições
  }

  Future<void> _favoriteSelected() async {
    final added = await context.read<GalleryController>().toggleFavorites(_selected.toList());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(added ? 'Adicionadas às favoritas' : 'Removidas das favoritas'),
    ));
    setState(_selected.clear);
  }

  Future<void> _deleteSelected() async {
    final n = _selected.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Excluir $n ${n > 1 ? 'imagens' : 'imagem'}?'),
        content: Text('Elas serão removidas do aparelho.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final deleted = await context.read<GalleryController>().service.delete(_selected.toList());
    if (!mounted) return;
    setState(() {
      _assets.removeWhere((a) => deleted.contains(a.id));
      _selected.clear();
    });
    context.read<GalleryController>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<GalleryController>();
    return Scaffold(
      appBar: AppBar(
        leading: _selecting
            ? IconButton(icon: const Icon(Icons.close), onPressed: () => setState(_selected.clear))
            : null,
        title: _selecting
            ? Text('${_selected.length} ${_selected.length > 1 ? 'selecionadas' : 'selecionada'}')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.folder.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  Text('${fmt(widget.folder.count)} imagens',
                      style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                ],
              ),
        actions: [
          if (_selecting)
            IconButton(
              tooltip: 'Favoritar',
              icon: const Icon(Icons.favorite_border),
              onPressed: _favoriteSelected,
            ),
          if (_selecting)
            IconButton(
              tooltip: 'Excluir',
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: _deleteSelected,
            ),
        ],
      ),
      body: _assets.isEmpty && _end
          ? const Center(child: Text('Esta pasta está vazia.', style: TextStyle(color: AppColors.muted)))
          : GridView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemCount: _assets.length,
              itemBuilder: (_, i) {
                final a = _assets[i];
                final sel = _selected.contains(a.id);
                return GestureDetector(
                  onTap: () => _selecting ? _toggle(a) : _open(i),
                  onLongPress: () => _toggle(a),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(fit: StackFit.expand, children: [
                      AssetEntityImage(
                        a,
                        isOriginal: false,
                        thumbnailSize: const ThumbnailSize.square(250),
                        fit: BoxFit.cover,
                      ),
                      if (sel) Container(color: Colors.black45),
                      if (_selecting)
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
                      if (fav.isFavorite(a.id))
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
    );
  }
}
```

---

## 12. Tela 5: visualizador

Ele usa um `PageView` (deslizar entre imagens) e um `InteractiveViewer` (zoom com pinça). Para economizar memória, carregue uma versão grande (1600 px), não o arquivo original. Se quiser o original, troque por `isOriginal: true`.

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

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir imagem?'),
        content: const Text('Esta imagem será removida do aparelho.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final service = context.read<GalleryController>().service;
    final deleted = await service.delete([_cur.id]); // vazio = o usuário negou
    if (deleted.isEmpty || !mounted) return;
    setState(() {
      _assets.removeAt(_index);
      if (_index >= _assets.length) _index = _assets.length - 1;
    });
    if (_assets.isEmpty) {
      Navigator.pop(context);
    } else {
      _toast('Imagem excluída');
    }
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0B),
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
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (_, i) => InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Center(
              child: AssetEntityImage(
                _assets[i],
                isOriginal: false,
                thumbnailSize: const ThumbnailSize(1600, 1600),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        if (_slide != null)
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: FilledButton(onPressed: _stopSlide, child: const Text('Parar slideshow')),
            ),
          ),
      ]),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 72,
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF1E2128)))),
          child: Row(children: [
            _Act(Icons.ios_share, 'Compartilhar', _share),
            _Act(Icons.delete_outline, 'Excluir', _delete, color: AppColors.danger),
            _Act(Icons.auto_fix_high, 'Editar', _edit),
            _Act(Icons.more_vert, 'Mais', _more),
          ]),
        ),
      ),
    );
  }
}

class _Act extends StatelessWidget {
  const _Act(this.icon, this.label, this.onTap, {this.color});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ]),
      ),
    );
  }
}
```

---

## 13. Ações do visualizador: o que cada uma faz de verdade

| Ação | Como é feita | Observação |
|---|---|---|
| Favoritar | `GalleryController.toggleFavorite` | Fica só no app. Se desinstalar, perde. |
| Excluir | `PhotoManager.editor.deleteWithIds` | No Android 11+ o sistema mostra a confirmação dele. Se o usuário negar, a lista volta vazia. |
| Copiar para | `copyAssetToPath`; plano B: `saveImage` com `relativePath` | O código tenta `copyAssetToPath` primeiro e, se falhar, regrava os bytes. |
| Mover para | Android ≤ 10: `moveAssetToAnother`. Android 11+: copiar e depois excluir | A documentação diz que o move direto não funciona no Android 11+. |
| Compartilhar | `share_plus` | Em versões novas do `share_plus` a API mudou (`SharePlus.instance.share`). Siga o exemplo da versão que você instalou. |
| Info | Propriedades de `AssetEntity` | `relativePath` só existe no Android. |
| Slideshow | `Timer.periodic` (2,2 s) + `PageController` | Volta à primeira depois da última. Cancele o timer no `dispose`. |

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
| 7 | Segurar uma imagem | Entra em seleção; favoritar marca todas; excluir pede confirmação |
| 8 | Abrir uma imagem, deslizar, dar zoom | Troca de imagem; pinça funciona |
| 9 | Favoritar, fechar e abrir o app | Favorito continua |
| 10 | Editar e salvar | Cópia `..._editada.jpg` aparece na mesma pasta |
| 11 | Copiar e mover para outra pasta | A pasta de destino ganha a imagem |
| 12 | Testar em Android 13/14 (acesso parcial) | O app mostra só o que foi liberado |

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
| `deleteWithIds` devolve lista vazia | Usuário negou o diálogo do sistema | Tratar como cancelamento, não como erro |
| Mover não funciona no Android 11+ | Limite do sistema | Copiar e excluir (já está no `moveTo`) |
| Favoritos somem | Sem persistência | `shared_preferences` (já está no controller) |
| Erro de nome de parâmetro | Versão do pacote diferente | Conferir a assinatura no autocompletar |
| Lista não atualiza após mudanças fora do app | Sem observador | Veja a seção 17 (`addChangeCallback`) |

---

## 17. Evoluções

1. **Atualizar sozinho** quando fotos mudam fora do app: `PhotoManager.addChangeCallback(...)` e `PhotoManager.startChangeNotify()`, chamando `controller.refresh()`.
2. **Vídeos:** troque `RequestType.image` por `RequestType.common` e mostre a duração (`asset.videoDuration`) como no protótipo.
3. **Lixeira:** no Android 11+ existe `PhotoManager.editor.android.moveToTrash(...)`, que é mais seguro que excluir direto.
4. **Mais ferramentas do protótipo:** Bloquear (pasta protegida com biometria), Imprimir (pacote `printing`), Definir como papel de parede (pacote específico), Abrir com (pacote de abrir arquivos). Veja a documentação de cada um antes de adotar.
5. **Ordem "mais antigas primeiro":** busque o álbum com `FilterOptionGroup` ordenado em ordem crescente de criação.
6. **Cache dos totais:** guarde os resultados do `scan()` (por exemplo com Isar ou Drift) para abrir o app mais rápido.
7. **Acesso parcial (Android 14 / iOS):** mostre um aviso "Você liberou só algumas fotos" com botão para `PhotoManager.openSetting()`.

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
  return ColorFilter.matrix(m);
}
```

Presets sugeridos (iguais aos do protótipo): Original (`identity`), P&B (`grayscale`), Sépia (`sepia`), Vívido (`saturationMatrix(1.5)`), Fade (`mul(brightnessMatrix(0.05), contrastMatrix(0.85))`).

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
