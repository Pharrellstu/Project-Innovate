import 'package:campuslink/screens/create_event_page.dart';
import 'package:campuslink/screens/chat_page.dart';    // ← import the ChatPage
import 'package:flutter/material.dart';
import 'package:campuslink/widgets/top_bar.dart';
import 'package:campuslink/widgets/nav_bar.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final List<_MessageItem> _messages = List.generate(
    4,
    (i) => _MessageItem(
      title: 'Pub Quiz',
      subtitle: 'this is a sample text',
      isUnread: i == 0,
      time: '10:03 AM',
      unreadCount: 2,
      avatarColor: Colors.blue,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        title: 'CampusLink',
      ),

      body: ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final item = _messages[index];
          return _buildMessageTile(context, item);
        },
      ),

      bottomNavigationBar: const NavBar(),
    );
  }

  Widget _buildMessageTile(BuildContext context, _MessageItem item) {
    return InkWell(
      onTap: () {
        // Navigate to ChatPage when tapped
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ChatPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: item.avatarColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.time,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${item.unreadCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageItem {
  final String title;
  final String subtitle;
  final String time;
  final bool isUnread;
  final int unreadCount;
  final Color avatarColor;

  _MessageItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.unreadCount,
    required this.avatarColor,
    this.isUnread = false,
  });
}
