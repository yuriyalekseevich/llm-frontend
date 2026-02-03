part of 'chat_cubit.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatSuccess extends ChatState {
  final LlmResponse response;

  const ChatSuccess({required this.response});

  @override
  List<Object?> get props => [response];
}

class ChatFailure extends ChatState {
  final String error;

  const ChatFailure({required this.error});

  @override
  List<Object?> get props => [error];
}