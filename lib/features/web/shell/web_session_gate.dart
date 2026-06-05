import 'package:autobus/barrel.dart';
import 'package:autobus/features/web/landing/landing.dart';
import 'package:autobus/features/web/shell/web_app_controller.dart';
import 'package:autobus/features/web/shell/web_app_loading_screen.dart';
/// Web landing entry that restores an existing session into the mobile app UI.
class WebSessionGate extends StatelessWidget {
  const WebSessionGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          WebAppController.instance.exitDashboardShell();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthWrapper()),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated ||
              state is AuthLoading ||
              state is TokenRefreshing) {
            return const WebAppLoadingScreen();
          }

          return const LandingPage();
        },
      ),
    );
  }
}
