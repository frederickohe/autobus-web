import 'package:autobus/barrel.dart';
import 'package:autobus/features/web/legal_web_paths.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class WebEntry extends StatelessWidget {
  const WebEntry({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      final legalPage = legalPageForWebPath(Uri.base.path);
      if (legalPage != null) {
        return legalPage;
      }
    }

    return const SplashWrapper();
  }
}
