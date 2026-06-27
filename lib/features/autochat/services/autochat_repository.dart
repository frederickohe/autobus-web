import 'dart:convert';

import 'package:autobus/config/app_config.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class CompanyLookupOption {
  final String companyNumber;
  final String displayName;

  const CompanyLookupOption({
    required this.companyNumber,
    required this.displayName,
  });

  factory CompanyLookupOption.fromJson(Map<String, dynamic> json) {
    return CompanyLookupOption(
      companyNumber: (json['company_number'] ?? '').toString(),
      displayName: (json['display_name'] ?? '').toString(),
    );
  }
}

class CompanyLookupResult {
  final bool ok;
  final bool requiresSelection;
  final String? companyNumber;
  final String? displayName;
  final String? message;
  final List<CompanyLookupOption> matches;

  const CompanyLookupResult({
    required this.ok,
    this.requiresSelection = false,
    this.companyNumber,
    this.displayName,
    this.message,
    this.matches = const [],
  });
}

class AutoChatRepository {
  final http.Client client;

  AutoChatRepository({http.Client? client}) : client = client ?? http.Client();

  Uri get _endpoint => Uri.parse(
        '${AppConfig.backendUrl}/api/v1/webhooks/start-dialog',
      );

  Uri _companyLookupUri(String name) => Uri.parse(
        '${AppConfig.backendUrl}/api/v1/webhooks/company-lookup',
      ).replace(queryParameters: {'name': name.trim()});

  /// Validate a business name before starting a public-site chat session.
  Future<CompanyLookupResult> lookupCompany(String companyName) async {
    final trimmed = companyName.trim();
    if (trimmed.length < 2) {
      return const CompanyLookupResult(
        ok: false,
        message: 'Enter the business name you want to chat with.',
      );
    }

    final res = await client.get(_companyLookupUri(trimmed));
    if (res.statusCode != 200) {
      return CompanyLookupResult(
        ok: false,
        message: 'Could not verify business name (${res.statusCode}).',
      );
    }

    final data = jsonDecode(res.body);
    if (data is! Map) {
      return const CompanyLookupResult(
        ok: false,
        message: 'Invalid lookup response.',
      );
    }

    final map = Map<String, dynamic>.from(data);
    final ok = map['ok'] == true;
    final rawMatches = map['matches'];
    final options = <CompanyLookupOption>[];
    if (rawMatches is List) {
      for (final item in rawMatches) {
        if (item is Map) {
          options.add(
            CompanyLookupOption.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return CompanyLookupResult(
      ok: ok,
      requiresSelection: map['requires_selection'] == true,
      companyNumber: (map['company_number'] ?? '').toString(),
      displayName: (map['display_name'] ?? '').toString(),
      message: (map['message'] ?? '').toString(),
      matches: options,
    );
  }

  /// Sends a message to the webhook and returns the bot reply as a ChatMessage.
  ///
  /// Provide [companyNumber] and/or [companyName] so the server can route to the
  /// merchant tenant for RAG-backed replies.
  Future<ChatMessage> sendMessage(
    String phone,
    String message, {
    String companyNumber = '',
    String companyName = '',
    String context = 'chatbot_agent',
  }) async {
    final trimmedCompany = companyNumber.trim();
    final trimmedName = companyName.trim();
    final Map<String, dynamic> body = {
      'customer_number': phone.trim(),
      'message': message,
      'context': context,
    };

    if (trimmedCompany.isNotEmpty) {
      body['company_number'] = trimmedCompany;
    }
    if (trimmedName.isNotEmpty) {
      body['company_name'] = trimmedName;
    }
    if (trimmedCompany.isEmpty && trimmedName.isEmpty) {
      body.remove('customer_number');
      body['userid'] = phone.trim();
    }

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
