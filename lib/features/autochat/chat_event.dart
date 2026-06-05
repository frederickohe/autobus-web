import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class SendMessage extends ChatEvent {
  final String phone;
  final String message;

  /// Merchant ``users.id`` for webhook ``company_number`` (scopes NLU per business).
  final String companyNumber;

  /// Backend webhook `context` (e.g. `order_agent`, `products_agent`).
  final String context;

  /// When true, the message is sent to the webhook but not shown in the UI.
  final bool hidden;

  /// When set, appended to the outbound webhook `message` (NLU) but not shown in the user bubble.
  ///
  /// Used for products chat: staged photos are uploaded first, then URLs are sent for slot filling.
  final List<String>? attachedProductImageUrls;

  const SendMessage({
    required this.phone,
    required this.message,
    required this.companyNumber,
    required this.context,
    this.hidden = false,
    this.attachedProductImageUrls,
  });

  @override
  List<Object?> get props => [
    phone,
    message,
    companyNumber,
    context,
    hidden,
    attachedProductImageUrls ?? const <String>[],
  ];
}

class LoadHistory extends ChatEvent {
  const LoadHistory();
}
