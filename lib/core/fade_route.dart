import 'package:flutter/material.dart';

/// Igual ao `@keyframes enter` do folio.html:
/// .22s ease-out, opacity 0→1 e translateX(14px)→0.
const _duration = Duration(milliseconds: 220);

Widget _enter(Animation<double> animation, Widget child) {
  final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
  return AnimatedBuilder(
    animation: curved,
    child: child,
    builder: (_, child) => Opacity(
      opacity: curved.value,
      child: Transform.translate(
        offset: Offset(14 * (1 - curved.value), 0),
        child: child,
      ),
    ),
  );
}

class FadeRoute<T> extends PageRouteBuilder<T> {
  FadeRoute(Widget page)
      : super(
          transitionDuration: _duration,
          reverseTransitionDuration: _duration,
          pageBuilder: (_, _, _) => page,
          transitionsBuilder: (_, animation, _, child) =>
              _enter(animation, child),
        );
}

/// Faz qualquer `MaterialPageRoute` (e diálogos de rota) usar a mesma transição.
class FadePageTransitionsBuilder extends PageTransitionsBuilder {
  const FadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      _enter(animation, child);
}

const fadePageTransitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: FadePageTransitionsBuilder(),
    TargetPlatform.iOS: FadePageTransitionsBuilder(),
    TargetPlatform.windows: FadePageTransitionsBuilder(),
    TargetPlatform.macOS: FadePageTransitionsBuilder(),
    TargetPlatform.linux: FadePageTransitionsBuilder(),
  },
);
