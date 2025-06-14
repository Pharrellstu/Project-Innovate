class ChatSummary {
  final int chatId;
  final int eventId;
  final String title;

  ChatSummary({
    required this.chatId,
    required this.eventId,
    required this.title,
  });
}

class ChatMessage {
  final int messageId;
  final int chatId;
  final int enrolledPersona;
  final String content;
  final DateTime createdAt;
  final int? attachmentId;

  ChatMessage({
    required this.messageId,
    required this.chatId,
    required this.enrolledPersona,
    required this.content,
    required this.createdAt,
    this.attachmentId,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      messageId: map['message_id'] as int,
      chatId: map['chat_id'] as int,
      enrolledPersona: map['enrolledpersona'] as int,
      content: map['messagecontent'] as String,
      createdAt: DateTime.parse(map['createdat'] as String),
      attachmentId: map['attachment_id'] as int?,
    );
  }
}
