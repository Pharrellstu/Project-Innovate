import 'package:flutter/material.dart';
import 'package:campuslink/models/chat_models.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: (message.author?.profilePictureUrl != null &&
                    message.author!.profilePictureUrl!.isNotEmpty)
                    ? NetworkImage(message.author!.profilePictureUrl!)
                    : null,
                child: (message.author?.profilePictureUrl == null ||
                    message.author!.profilePictureUrl!.isEmpty)
                    ? Text(message.author!.username?[0].toUpperCase() ?? 'U')
                    : null,
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Text(
                    message.author?.username ?? 'Unknown User',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                  ),
                if (!isMe) const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? Theme.of(context).primaryColor : Colors.white,
                    borderRadius: isMe
                        ? const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    )
                        : const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            message.imageUrl!,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (message.text.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: message.imageUrl != null ? 8.0 : 0),
                          child: Text(
                            message.text,
                            style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    DateFormat('HH:mm').format(message.createdAt),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

