import 'package:equatable/equatable.dart';

abstract class AssistantEvent extends Equatable {
  const AssistantEvent();

  @override
  List<Object?> get props => [];
}

class SendCommandEvent extends AssistantEvent {
  final String command;

  const SendCommandEvent({required this.command});

  @override
  List<Object?> get props => [command];
}
