import 'package:autobus/barrel.dart';
import 'package:autobus/features/web/shell/web_session_gate.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  @override
  void initState() {
    super.initState();
    print('=== SPLASH SCREEN SHOWING ===');

    if (kIsWeb) {
      // Web should start on the marketing landing page; no forced navigation.
      return;
    }

    Future.delayed(const Duration(seconds: 3), () {
      print('=== SPLASH TIMEOUT - NAVIGATING TO AUTH ===');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const WebSessionGate();
    return const SplashPge();
  }
}
