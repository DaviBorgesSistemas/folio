import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionAccessController {
  PermissionAccessController() {
    refresh();
  }

  final ValueNotifier<bool> granted = ValueNotifier(false);

  /// Lê o status atual da permissão e atualiza [granted].
  Future<void> refresh() async {
    granted.value = await Permission.manageExternalStorage.isGranted;
  }

  /// Abre a tela de configurações para o usuário ativar a permissão.
  Future<void> requestPermission() async {
    await Permission.manageExternalStorage.request();
    await refresh();
  }

  void dispose() => granted.dispose();
}
