import 'package:flutter/material.dart';
import 'package:folio/core/context_ext.dart';
import 'package:folio/screens/splash/widgets/loading_dots.dart';
import 'package:folio/screens/welcome/welcome_screen.dart';
import 'package:folio/screens/splash/widgets/splash_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _dotsExitOpacity;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _dotsExitOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _leave() async {
    await _c.forward(); 
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) => const WelcomeScreen(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(alignment: Alignment.center, child: SplashLogo(onDone: _leave)),
          Positioned(
            left: 0,
            right: 0,
            bottom: 56 + context.safeBottom, 
            child: Center(
              child: FadeTransition(
                opacity: _dotsExitOpacity,
                child: const LoadingDots(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
