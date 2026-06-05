import 'dart:convert';

import 'package:autobus/config/app_config.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class AutoChatRepository {
  final http.Client client;

  AutoChatRepository({http.Client? client}) : client = client ?? http.Client();

  Uri get _endpoint => Uri.parse(
        '${AppConfig.backendUrl}/api/v1/webhooks/start-dialog',
      );

  /// Sends a message to the webhook and returns the bot reply as a ChatMessage.
  ///
  /// [companyNumber] is the merchant ``users.id`` (`company_number` on the API).
  /// When empty, the server uses legacy ``userid``-only routing.
  ///
  /// [context] is kept for forward compatibility (server may use it later).
  Future<ChatMessage> sendMessage(
    String phone,
    String message, {
    required String companyNumber,
    required String context,
  }) async {
    final trimmedCompany = companyNumber.trim();
    final body = trimmedCompany.isEmpty
        ? {
            'userid': phone,
            'message': message,
            'context': context,
          }
        : {
            'customer_number': phone,
            'company_number': trimmedCompany,
            'message': message,
            'context': context,
          };

    final res = await client.post(
      _endpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('AutoChat API error: ${res.statusCode}');
    }

    final data = jsonDecode(res.body);
    final replyText =
        (data['message'] ??
                data['reply'] ??
                data['response'] ??
                data['text'] ??
                '')
            .toString();

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: phone,
      text: replyText,
      timestamp: DateTime.now(),
      sender: Sender.bot,
      status: MessageStatus.sent,
    );
  }
}
