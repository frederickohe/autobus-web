import 'package:equatable/equatable.dart';
import 'models/chat_message.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoadInProgress extends ChatState {}

class ChatLoadSuccess extends ChatState {
  final List<ChatMessage> messages;

  const ChatLoadSuccess(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatLoadFailure extends ChatState {
  final String error;

  const ChatLoadFailure(this.error);

  @override
  List<Object?> get props => [error];
}
