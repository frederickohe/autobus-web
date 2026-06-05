import 'package:equatable/equatable.dart';

enum Sender { user, bot }

enum MessageStatus { pending, sent, failed }

class ChatMessage extends Equatable {
  final String id;
  final String userId;
  final String text;
  final DateTime timestamp;
  final Sender sender;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.userId,
    required this.text,
    required this.timestamp,
    required this.sender,
    required this.status,
  });

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    required String userId,
    Sender sender = Sender.bot,
    MessageStatus status = MessageStatus.sent,
  }) {
    return ChatMessage(
      id: (json['id'] ?? DateTime.now().millisecondsSinceEpoch).toString(),
      userId: userId,
      text:
          (json['message'] ??
                  json['reply'] ??
                  json['response'] ??
                  json['text'] ??
                  '')
              .toString(),
      timestamp: DateTime.now(),
      sender: sender,
      status: status,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'sender': sender.toString(),
    'status': status.toString(),
  };

  ChatMessage copyWith({
    String? id,
    String? userId,
    String? text,
    DateTime? timestamp,
    Sender? sender,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      sender: sender ?? this.sender,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, userId, text, timestamp, sender, status];
}
