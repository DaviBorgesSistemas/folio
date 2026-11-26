import 'package:flutter/material.dart';

class FadeRoute<T> extends PageRouteBuilder<T> {
  FadeRoute(Widget page)
      : super(
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, _, _) => page,
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        );
}

/// Faz qualquer `MaterialPageRoute` (e diálogos de rota) usar o mesmo fade.
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
      FadeTransition(opacity: animation, child: child);
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
