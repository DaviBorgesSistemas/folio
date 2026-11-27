import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:folio/screens/read_device/device_scanner.dart';
import 'package:folio/screens/read_device/scan_models.dart';

// EXPLICA: o controller é a "ponte" entre a leitura (device_scanner.dart) e a
// tela. Ele escuta o Stream, guarda o último estado e avisa a tela quando
// muda. Assim a tela não precisa saber nada sobre Stream nem sobre erros.
//
// `ChangeNotifier` é a classe do Flutter para isso: quando chamamos
// `notifyListeners()`, quem estiver escutando (o ListenableBuilder da tela)
// reconstrói.
/// Guarda o estado da leitura e avisa a tela a cada mudança.
class ReadDeviceController extends ChangeNotifier {
  ReadDeviceController() {
    // EXPLICA: a leitura começa aqui, no momento em que o controller é
    // criado. `listen` registra o que fazer em cada situação do Stream.
    _subscription = scanDevice().listen(
      _onProgress, // chegou um novo ScanState
      onDone: _onDone, // o Stream acabou sem erro
      onError: _onError, // algo deu errado (ex.: sem permissão)
      cancelOnError: true, // após um erro, para de escutar
    );
  }

  // EXPLICA: começa em "preparando" para a tela já nascer mostrando o
  // loading, antes mesmo da primeira emissão do Stream.
  ScanState _state = ScanState.preparing;
  bool _isDone = false;
  bool _hasFailed = false;

  // EXPLICA: guardamos a "assinatura" do Stream para poder cancelá-la no
  // dispose. Sem isso a leitura continuaria rodando depois de sair da tela.
  StreamSubscription<ScanState>? _subscription;

  // EXPLICA: a tela só LÊ estes getters. Os campos com "_" são privados, então
  // só o controller consegue alterá-los.
  ScanState get state => _state;

  /// A leitura terminou com sucesso.
  bool get isDone => _isDone;

  /// A leitura falhou (ex.: sem permissão de acesso aos arquivos).
  bool get hasFailed => _hasFailed;

  void _onProgress(ScanState state) {
    _state = state;
    notifyListeners(); // avisa a tela para se redesenhar
  }

  void _onDone() {
    _isDone = true;
    notifyListeners();
  }

  void _onError(Object _) {
    _hasFailed = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel(); // para a leitura se a tela for fechada
    super.dispose();
  }
}
