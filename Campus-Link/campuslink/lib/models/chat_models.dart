import 'package:campuslink/models/user.dart';

// Represents a single message within a chat room.
class ChatMessage {
  final String id;
  final int chatId;
  final String text;
  final DateTime createdAt;
  final int authorAccountId;
  final String? imageUrl;

  // Holds the user details for the author of the message.
  // This is populated in the service layer to avoid extra lookups in the UI.
  final UserObject? author;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.text,
    required this.createdAt,
    required this.authorAccountId,
    this.author,
    this.imageUrl,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, {UserObject? author}) {
    return ChatMessage(
      id: map['message_id'].toString(),
      chatId: map['chat_id'],
      authorAccountId: map['enrolledpersona'],
      text: map['messagecontent'] ?? '',
      createdAt: DateTime.parse(map['createdat']).toLocal(),
      // The attachment URL is fetched via a join in the service.
      imageUrl: (map['messageattachment'] as Map<String, dynamic>?)?['fileurl'],
      author: author,
    );
  }
}

// Represents a chat conversation in the chat list.
class ChatSummary {
  final int chatId;
  final String eventName;
  final String? eventImageUrl;
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final int unreadCount;

  ChatSummary({
    required this.chatId,
    required this.eventName,
    this.eventImageUrl,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    this.unreadCount = 0,
  });
}
