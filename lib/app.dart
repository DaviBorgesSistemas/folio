import 'package:flutter/material.dart';
import 'package:folio/core/theme.dart';
import 'package:folio/screens/splash/splash_screen.dart';
import 'package:folio/widgets/app_background.dart';

class FolioApp extends StatelessWidget {
  const FolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Folio',
          debugShowCheckedModeBanner: false,
      theme: buildTheme(),
            builder: (context, child) => AppBackground(child: child!), // fundo do vidro
      home: const SplashScreen(),);
  }
}
