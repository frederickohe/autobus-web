import 'package:autobus/barrel.dart';
import 'package:autobus/features/legal/privacy_policy_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class WebEntry extends StatelessWidget {
  const WebEntry({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      final path = Uri.base.path.toLowerCase();
      if (path == '/privacy' || path == '/privacy-policy') {
        return const PrivacyPolicyPage();
      }
    }

    return const SplashWrapper();
  }
}
