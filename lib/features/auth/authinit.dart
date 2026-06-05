import 'package:autobus/barrel.dart';
import 'package:autobus/features/subscription/subscription_guard.dart';
import 'package:autobus/features/web/landing/landing.dart';
import 'package:autobus/features/web/shell/web_app_controller.dart';
import 'package:autobus/features/web/shell/web_app_loading_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle session expiration
        if (state is SessionExpired) {
          WebAppController.instance.exitDashboardShell();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => kIsWeb ? const LandingPage() : const LogorSign(),
            ),
            (route) => false,
          );
        }
        // Handle token refresh failure
        else if (state is TokenRefreshFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Session error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          print('=== AuthWrapper State: ${state.runtimeType} ===');

          if (state is Authenticated) {
            if (kIsWeb) {
              WebAppController.instance.exitDashboardShell();
            }
            print('✓ User is Authenticated');
            final dynamic u = state.user;
            final userMap = (u is Map<String, dynamic>)
                ? u
                : (u is Map
                      ? Map<String, dynamic>.from(u)
                      : <String, dynamic>{});
            return SubscriptionGuard(user: userMap);
          } else if (state is Unauthenticated) {
            WebAppController.instance.exitDashboardShell();
            print('✗ User is Unauthenticated - showing Signin');
            return const Signin();
          } else if (state is SessionExpired) {
            WebAppController.instance.exitDashboardShell();
            print('✗ Session Expired - showing LogorSign');
            return kIsWeb ? const LandingPage() : const LogorSign();
          } else if (state is AuthError) {
            print('✗ Auth Error: ${state.message}');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            });
            // Render relevant page based on error source
            if (state.source == 'signup') {
              return const Signup();
            } else {
              return const Signin();
            }
          } else if (state is TokenRefreshing) {
            print('⏳ Token Refreshing...');
            if (kIsWeb) return const WebAppLoadingScreen();
            return const Scaffold(
              body: Center(child: AutobusLoadingIndicator()),
            );
          } else if (state is TokenRefreshFailed) {
            print('✗ Token Refresh Failed: ${state.message} - showing Signin');
            return const Signin();
          } else {
            print('⏳ Initial Loading State: $state');
            if (kIsWeb) return const WebAppLoadingScreen();
            return const Scaffold(
              body: Center(child: AutobusLoadingIndicator()),
            );
          }
        },
      ),
    );
  }
}
