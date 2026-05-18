import 'package:echo_explorer/features/chat/data/models/message_model.dart';
import 'package:echo_explorer/features/chat/domain/entities/session_entity.dart';

class SessionModel extends SessionEntity {
  SessionModel({
    required super.id,
    required super.title,
    super.artifactId,
    required super.language,
    required super.messageCount,
    required super.startedAt,
    required super.updatedAt,
    super.messages,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      artifactId: json['artifactId'],
      language: json['language'] ?? 'en',
      messageCount: json['messageCount'] ?? 0,
      startedAt: DateTime.tryParse(json['startedAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      messages: json['messages'] != null
          ? (json['messages'] as List).map((m) => MessageModel.fromJson(m)).toList()
          : null,
    );
  }
}
