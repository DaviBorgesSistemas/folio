import 'package:flutter/material.dart';

/// Atalhos para dados da tela, sem repetir `MediaQuery.of(context)`.
///
/// Uso: `context.width`, `context.height`, `context.safeBottom`...
extension ScreenContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);

  double get width => screenSize.width;
  double get height => screenSize.height;

  /// Áreas ocupadas pelo sistema (barra de status, barra de navegação, notch).
  /// Com edge-to-edge, é o espaço que o conteúdo precisa respeitar.
  EdgeInsets get safePadding => MediaQuery.paddingOf(this);
  double get safeTop => safePadding.top;
  double get safeBottom => safePadding.bottom;

  /// Altura que sobra para o conteúdo, sem as barras do sistema.
  double get usableHeight => height - safeTop - safeBottom;

  /// Porcentagem da tela: `context.wp(50)` é metade da largura.
  double wp(double percent) => width * percent / 100;
  double hp(double percent) => height * percent / 100;

  /// Celulares pequenos (largura menor que 360 dp).
  bool get isSmallScreen => width < 360;

  Orientation get orientation => MediaQuery.orientationOf(this);
  bool get isLandscape => orientation == Orientation.landscape;
}
