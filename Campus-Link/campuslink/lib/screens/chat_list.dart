import 'package:flutter/material.dart';
import 'package:campuslink/services/db_handler.dart' ;
import 'package:campuslink/services/auth_gate.dart';
import 'package:campuslink/screens/chat_page.dart';
import 'package:campuslink/widgets/top_bar.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/services/chatlist.dart';
import 'package:campuslink/services/chatlist_service.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  late Future<List<ChatSummary>> _futureChats;

  @override
  void initState() {
    super.initState();
    _futureChats = chat_service.fetchChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: 'CampusLink'),
      body: FutureBuilder<List<ChatSummary>>(
        future: _futureChats,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          }
          final chats = snapshot.data ?? [];
          if (chats.isEmpty) {
            return const Center(child: Text('No chats available'));
          }
          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(chat.title.isNotEmpty ? chat.title[0] : '?'),
                ),
                title: Text(chat.title),
                subtitle: Text('Event ID: ${chat.eventId}'),
                onTap: () {
                  final userId = AuthGate.getCurrentUserId();
                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please log in to join chats')),
                    );
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatPage(chatId: chat.chatId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: const NavBar(),
    );
  }
}
