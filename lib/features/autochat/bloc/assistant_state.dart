import 'package:equatable/equatable.dart';

abstract class AssistantState extends Equatable {
  const AssistantState();

  @override
  List<Object?> get props => [];
}

class AssistantInitial extends AssistantState {}

class AssistantLoading extends AssistantState {}

class AssistantSuccess extends AssistantState {
  final String response;

  const AssistantSuccess({required this.response});

  @override
  List<Object?> get props => [response];
}

class AssistantError extends AssistantState {
  final String message;

  const AssistantError({required this.message});

  @override
  List<Object?> get props => [message];
}
