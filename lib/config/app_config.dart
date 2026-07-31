import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static late String _backendUrl;
  static late String paystackPublicKey;
  static late String paystackCallbackUrl;
  static late String publicWebhookApiKey;

  static Future<void> init() async {
    await dotenv.load();
    _backendUrl = dotenv.env['BACKEND_URL'] ?? 'http://localhost:8000';
    paystackPublicKey = dotenv.env['PAYSTACK_PUBLIC_KEY'] ?? '';
    paystackCallbackUrl = dotenv.env['PAYSTACK_CALLBACK_URL'] ?? '';
    publicWebhookApiKey = dotenv.env['PUBLIC_WEBHOOK_API_KEY'] ?? '';
  }

  static String get backendUrl => _backendUrl;

  /// Headers for marketing webhook helpers (company lookup / public chat).
  static Map<String, String> webhookHeaders({
    Map<String, String>? extra,
  }) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      ...?extra,
    };
    if (publicWebhookApiKey.isNotEmpty) {
      headers['X-Api-Key'] = publicWebhookApiKey;
    }
    return headers;
  }
}
