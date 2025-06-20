import 'package:flutter/material.dart';
import 'package:campuslink/models/chat_models.dart';
import 'package:campuslink/services/chat_service.dart';
import 'package:campuslink/screens/chat_page.dart';
import 'package:intl/intl.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late Future<List<ChatSummary>> _chatsFuture;
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() {
    _chatsFuture = _chatService.fetchChatSummaries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadChats();
          });
        },
        child: FutureBuilder<List<ChatSummary>>(
          future: _chatsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('An error occurred: ${snapshot.error}'));
            }

            final chats = snapshot.data;
            if (chats == null || chats.isEmpty) {
              return const Center(
                child: Text(
                  'No chats yet.\nJoin an event to start chatting!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return _buildChatListItem(chat);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildChatListItem(ChatSummary chat) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: (chat.eventImageUrl != null && chat.eventImageUrl!.isNotEmpty)
            ? NetworkImage(chat.eventImageUrl!)
            : null,
        child: (chat.eventImageUrl == null || chat.eventImageUrl!.isEmpty)
            ? Text(
          chat.eventName.isNotEmpty ? chat.eventName[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white, fontSize: 24),
        )
            : null,
        backgroundColor: Colors.grey.shade400,
      ),
      title: Text(
        chat.eventName,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        chat.lastMessage,
        style: TextStyle(color: Colors.grey.shade600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        DateFormat('HH:mm').format(chat.lastMessageTimestamp.add( Duration (hours: 2))),
        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ChatPage(
            chatId: chat.chatId,
            chatTitle: chat.eventName,
          ),
        ));
      },
    );
  }
}