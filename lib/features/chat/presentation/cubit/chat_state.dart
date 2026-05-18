part of 'chat_cubit.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<MessageEntity> messages;
  final String? artifactTitle;
  ChatLoaded({required this.messages, this.artifactTitle});
}

class ChatBotLoading extends ChatState {
  final List<MessageEntity> messages;
  ChatBotLoading({required this.messages});
}

class ChatError extends ChatState {
  final List<MessageEntity> messages;
  final String message;
  ChatError({required this.messages, required this.message});
}

class SessionsLoaded extends ChatState {
  final List<SessionEntity> sessions;
  SessionsLoaded({required this.sessions});
}
