// EXPLICA: aqui mora a leitura de verdade do aparelho. É Dart puro: não
// importa nenhum widget. Isso permite testar/trocar a leitura sem mexer na UI.

import 'dart:io';

import 'package:folio/screens/read_device/scan_models.dart';
import 'package:permission_handler/permission_handler.dart';

// EXPLICA: raiz do armazenamento interno do Android. Não lê cartão SD.
const _storageRoot = '/storage/emulated/0';

// EXPLICA: um arquivo conta como imagem se a extensão estiver neste conjunto.
// Usar Set deixa o `contains` rápido.
const _imageExtensions = {
  'jpg',
  'jpeg',
  'png',
  'gif',
  'webp',
  'bmp',
  'heic',
  'heif',
};

/// A cada quantas pastas sem imagem a barra de progresso é atualizada
/// (evita redesenhar a tela milhares de vezes à toa).
const _progressStep = 25;

// EXPLICA: `Stream` é uma "fila de valores ao longo do tempo". `async*` +
// `yield` permitem emitir um ScanState sempre que algo muda, e a tela escuta
// e se redesenha a cada emissão. Diferente de um Future, que entrega um
// único valor no fim.
/// Lê o armazenamento, uma pasta por vez, emitindo o progresso.
/// Só entram na lista as pastas que têm pelo menos uma imagem.
Stream<ScanState> scanDevice() async* {
  // EXPLICA: se isto lançar erro, o Stream termina com erro e o controller
  // marca `hasFailed`, que faz a tela mostrar o ScanErrorView.
  await _ensureStorageAccess();

  // EXPLICA: fase 1 ("preparando"). Lista TODAS as pastas antes de contar,
  // porque só assim sabemos o total e podemos calcular a porcentagem. É essa
  // etapa que demora e que mostra o loading na tela.
  final folders = await _listFolders(Directory(_storageRoot));

  var found = 0;
  final rows = <ScanRow>[];

  // EXPLICA: função local que "tira uma foto" do progresso atual. Usa
  // `List.of(rows)` para copiar a lista: se passássemos a mesma lista, o
  // estado antigo mudaria junto com a lista e a tela não perceberia a mudança.
  ScanState snapshot(int checked) => ScanState(
    found: found,
    progress: checked / folders.length,
    rows: List.of(rows),
  );

  // EXPLICA: primeira emissão com isPreparing = false. É isso que troca o
  // loading pela lista na tela.
  yield snapshot(0);

  // EXPLICA: fase 2. Conta as imagens de cada pasta, uma de cada vez.
  for (var i = 0; i < folders.length; i++) {
    final folder = folders[i];
    final count = await _countImages(folder);

    // EXPLICA: pasta sem imagem não aparece na lista. Só atualizamos a barra
    // de vez em quando (a cada _progressStep) para não redesenhar a tela
    // milhares de vezes. `continue` pula para a próxima pasta.
    if (count == 0) {
      if (i % _progressStep == 0) yield snapshot(i);
      continue;
    }

    final name = _baseName(folder.path);

    // EXPLICA: 1º passo da pasta: entra na lista "em andamento" (isDone: false),
    // com spinner e contagem 0.
    rows.add(ScanRow(name: name, path: folder.path, count: 0, isDone: false));
    yield snapshot(i);

    // EXPLICA: 2º passo: troca a mesma linha pela versão concluída, com o ✓ e
    // a contagem final. `rows.length - 1` é a posição da última linha.
    found += count;
    rows[rows.length - 1] = ScanRow(
      name: name,
      path: folder.path,
      count: count,
      isDone: true,
    );
    yield snapshot(i + 1);
  }

  // EXPLICA: garante 100% no fim, mesmo que as últimas pastas fossem vazias.
  yield snapshot(folders.length);
}

/// O acesso vem de "Acesso a todos os arquivos", concedido na tela de permissão.
Future<void> _ensureStorageAccess() async {
  if (!await Permission.manageExternalStorage.isGranted) {
    throw StateError('Sem acesso a todos os arquivos');
  }
}

/// Lista todas as pastas do armazenamento, ignorando as ocultas (que começam
/// com ".") e a pasta `Android` (dados privados de outros apps).
Future<List<Directory>> _listFolders(Directory root) async {
  final all = <Directory>[root];

  // EXPLICA: percorre a árvore de pastas sem recursão, usando uma fila
  // (`pending`). Tira uma pasta, olha o que tem dentro, e empilha as
  // subpastas para visitar depois. Termina quando a fila esvazia.
  final pending = <Directory>[root];

  while (pending.isNotEmpty) {
    final parent = pending.removeLast();
    try {
      // EXPLICA: `followLinks: false` evita entrar em atalhos (links
      // simbólicos), que poderiam criar um loop infinito.
      await for (final entity in parent.list(followLinks: false)) {
        if (entity is! Directory) continue; // só interessam as pastas
        if (_shouldSkip(entity, parent, root)) continue;
        all.add(entity);
        pending.add(entity);
      }
    } catch (_) {
      // EXPLICA: algumas pastas do sistema não deixam ler. Em vez de quebrar
      // a leitura inteira, ignoramos e seguimos para a próxima.
    }
  }
  return all;
}

bool _shouldSkip(Directory folder, Directory parent, Directory root) {
  final name = _baseName(folder.path);
  final isHidden = name.startsWith('.');
  // EXPLICA: `Android/` só é ignorada na raiz. Lá ficam dados privados de
  // outros apps, que não são galeria e deixariam a leitura muito mais lenta.
  final isAndroidData = parent.path == root.path && name == 'Android';
  return isHidden || isAndroidData;
}

/// Conta as imagens que estão direto dentro da pasta (sem as subpastas).
Future<int> _countImages(Directory folder) async {
  var count = 0;
  try {
    await for (final entity in folder.list(followLinks: false)) {
      if (entity is File && _isImage(entity.path)) count++;
    }
  } catch (_) {
    // pasta sem permissão de leitura: conta o que deu para ler
  }
  return count;
}

bool _isImage(String path) {
  final dot = path.lastIndexOf('.');
  if (dot < 0) return false; // arquivo sem extensão
  return _imageExtensions.contains(path.substring(dot + 1).toLowerCase());
}

// EXPLICA: pega o último pedaço do caminho ("/a/b/WhatsApp" -> "WhatsApp").
// Aceita "/" e "\" para funcionar em qualquer sistema.
String _baseName(String path) => path.split(RegExp(r'[\\/]')).last;
