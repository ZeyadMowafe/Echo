import 'package:echo_explorer/features/chat/domain/entities/message_entity.dart';

class SessionEntity {
  final String id;
  final String title;
  final String? artifactId;
  final String language;
  final int messageCount;
  final DateTime startedAt;
  final DateTime updatedAt;
  final List<MessageEntity>? messages;

  SessionEntity({
    required this.id,
    required this.title,
    this.artifactId,
    required this.language,
    required this.messageCount,
    required this.startedAt,
    required this.updatedAt,
    this.messages,
  });
}
