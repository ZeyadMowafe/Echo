import 'package:echo_explorer/features/chat/domain/entities/chat_reply_entity.dart';

class ChatReplyModel extends ChatReplyEntity {
  ChatReplyModel({required super.reply, required super.sessionId, required super.success});

  factory ChatReplyModel.fromJson(Map<String, dynamic> json) {
    return ChatReplyModel(
      reply: json['reply'] ?? '',
      sessionId: json['sessionId'] ?? '',
      success: json['success'] ?? false,
    );
  }
}
