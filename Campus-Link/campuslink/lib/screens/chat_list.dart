import 'package:campuslink/screens/create_event_page.dart';
import 'package:flutter/material.dart';


class CampusLinkPage extends StatefulWidget {
  @override
  _CampusLinkPageState createState() => _CampusLinkPageState();
}

class _CampusLinkPageState extends State<CampusLinkPage> {
  // this is a sample data model for each message item and it hard coded data
  // In a real app, you would fetch this from a backend or database.
  final List<_MessageItem> _messages = List.generate(
    4,
    (i) => _MessageItem(
      title: 'Pub Quiz',
      subtitle: 'this is a sample text',
      isUnread: i == 0, // First item is unread
      time: '10:03 AM',
      unreadCount: 2,
      // this would be replaced with the actual avatar that has been saved for each user in the database 
      avatarColor: Colors.blue, 
    ),
  );

  // in the bottom navigation bar, the selected index is set to 2 since chat is the third item
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1) AppBar with back arrow, title, and “+” button
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'CampusLink',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Image.asset("resources/icons/newPostBtn.png"),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CreateEventPage()),
              );
            },
          ),
        ],
      ),

      // The body is a ListView.builder that displays each message row
      body: ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final item = _messages[index];
          return _buildMessageTile(item);
        },
      ),

      // Bottom navigation bar with four icons
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue, // highlight color for selected icon
        unselectedItemColor: Colors.grey,
        onTap: (int newIndex) {
          setState(() {
            _selectedIndex = newIndex;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  /// Builds one row (“message tile”) exactly as shown in your screenshot.
  Widget _buildMessageTile(_MessageItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Circular avatar (just a colored circle for now)
          CircleAvatar(
            radius: 24,
            backgroundColor: item.avatarColor,
            // Placeholder for avatar image
          ),

          const SizedBox(width: 12),

          // Title and subtitle in a column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Right‐side: Time and unread count badge
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${item.unreadCount}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
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