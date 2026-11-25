import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:folio/app.dart';
import 'package:folio/core/app_orientation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppOrientation.lockPortrait();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false, // sem a faixa translúcida que o Android põe sozinho
    statusBarIconBrightness: Brightness.light,  // ícones claros, porque o fundo é escuro
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const FolioApp());
}
