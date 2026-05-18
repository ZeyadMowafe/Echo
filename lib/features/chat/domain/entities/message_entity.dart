class MessageEntity {
  final String id;
  final String role;
  final String content;
  final String? responseToId;
  final DateTime createdAt;

  MessageEntity({
    required this.id,
    required this.role,
    required this.content,
    this.responseToId,
    required this.createdAt,
  });
}
