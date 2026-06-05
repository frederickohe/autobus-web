import 'package:autobus/barrel.dart';

/// Full-screen branded loader for web auth and subscription resolution.
class WebAppLoadingScreen extends StatelessWidget {
  const WebAppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF130522), Color(0xFF2D0C51), Color(0xFF130522)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: AutobusLoadingIndicator(size: 48),
        ),
      ),
    );
  }
}
