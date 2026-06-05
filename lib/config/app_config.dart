import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static late String _backendUrl;
  static late String paystackPublicKey;
  static late String paystackCallbackUrl;

  static Future<void> init() async {
    await dotenv.load();
    _backendUrl = dotenv.env['BACKEND_URL'] ?? 'http://localhost:8000';
    paystackPublicKey = dotenv.env['PAYSTACK_PUBLIC_KEY'] ?? '';
    paystackCallbackUrl = dotenv.env['PAYSTACK_CALLBACK_URL'] ?? '';
  }

  static String get backendUrl => _backendUrl;
}
