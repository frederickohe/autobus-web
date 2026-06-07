import 'package:autobus/barrel.dart';
import 'package:autobus/features/web/shell/web_app_controller.dart';
import 'package:autobus/features/web/shell/web_dashboard_shell.dart';
import 'package:autobus/features/web/legal_web_paths.dart';
import 'package:autobus/features/web/web_entry.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// Initialize services at app level
late TokenService _tokenService;
late SessionAwareHttpClient _httpClient;
late ApiService _apiService;
late PaystackService _paystackService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  print('=== APP STARTING ===');

  // Initialize environment variables
  await AppConfig.init();
  print('✓ AppConfig initialized');

  // Initialize Google Fonts
  await GoogleFonts.pendingFonts([GoogleFonts.montserrat()]);
  print('✓ Google Fonts loaded');

  // Initialize session handling services
  _tokenService = TokenService();
  _httpClient = SessionAwareHttpClient(
    tokenService: _tokenService,
    baseUrl: AppConfig.backendUrl,
  );
  _apiService = ApiService(httpClient: _httpClient);

  _paystackService = PaystackService();
  print('✓ Services initialized');

  // Create blocs
  final successBloc = SuccessBloc();
  final authBloc = AuthBloc(
    tokenService: _tokenService,
    successBloc: successBloc,
  );
  print('✓ BLoCs created');

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiService>(create: (context) => _apiService),
        RepositoryProvider<PaystackService>(
          create: (context) => _paystackService,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc..add(CheckSessionEvent())),
          BlocProvider.value(value: successBloc),
          BlocProvider(create: (context) => AssistantBloc()),
          BlocProvider(create: (context) => ThemeBloc()),
        ],
        child: MyApp(httpClient: _httpClient),
      ),
    ),
  );
  print('=== APP INITIALIZED ===');
}

//Getters
SessionAwareHttpClient get appHttpClient => _httpClient;
ApiService get apiService => _apiService;
TokenService get tokenService => _tokenService;
PaystackService get paystackService => _paystackService;

class MyApp extends StatelessWidget {
  final SessionAwareHttpClient httpClient;

  const MyApp({required this.httpClient, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return ListenableBuilder(
          listenable: WebAppController.instance,
          builder: (context, _) {
            return MaterialApp(
              navigatorKey: NavigationService.navigatorKey,
              debugShowCheckedModeBanner: false,
              title: 'Autobus',
              theme: state.themeData,
              builder: (context, child) {
                if (kIsWeb) {
                  if (isLegalWebPath(Uri.base.path)) {
                    return child ?? const SizedBox.shrink();
                  }
                  if (WebAppController.instance.useDashboardShell) {
                    return const WebDashboardShell();
                  }
                }
                return child ?? const SizedBox.shrink();
              },
              home: const WebEntry(),
            );
          },
        );
      },
    );
  }
}
