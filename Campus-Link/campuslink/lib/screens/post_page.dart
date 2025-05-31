import 'package:flutter/material.dart';

class PostPage extends StatefulWidget {
  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  // Dummy data
  final String userName = 'Think Wireless';
  final String title = 'Friday Pub Quiz Night';
  final String date = '09 May | 19:45';
  final String location = 'Matissepassage 16, Emmen';
  final String description =
      'Gather your mates and put your brains to the test at our lively Pub Quiz! Fun questions, cold drinks, and bragging rights up for grabs!';

  // Comment-related state
  final TextEditingController _commentController = TextEditingController();
  final List<Comment> comments = [
    Comment(user: 'Peter Kapsiar', text: 'Yall are getting clapped'),
    Comment(
        user: 'Name',
        text:
            'I am so excited. Was amazing last time. Cant wait to see you there. 😁'),
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      comments.insert(0, Comment(user: userName, text: text.trim()));
    });
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Post'),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Header row: avatar, name, “New event” tag, see profile
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage:
                    AssetImage('resources/icons/profile_placeholder.png'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(userName,
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('New event',
                    style: TextStyle(color: Colors.blue.shade800)),
              ),
              const SizedBox(width: 8),
              TextButton(onPressed: () {}, child: Text('See profile')),
            ],
          ),
          const SizedBox(height: 12),

          // Event card with local asset image
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'resources/img/PubQuiz.png',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black26,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Icon(Icons.edit, color: Colors.white),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date, style: TextStyle(color: Colors.white70)),
                    Text(title,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    Text(location, style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Text(description, style: TextStyle(fontSize: 16)),
          const SizedBox(height: 16),

          // Icons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _IconLabel(icon: Icons.lightbulb_outline, label: 'Pub Quiz'),
              _IconLabel(icon: Icons.person, label: userName),
              _IconLabel(icon: Icons.calendar_today, label: '14/5/2024'),
              _IconLabel(icon: Icons.location_on, label: 'Bar Hop'),
            ],
          ),
          const SizedBox(height: 16),

          // Attendance avatars (unchanged)
          Row(
            children: [
              Text('Attendance:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              // ... avatars here ...
            ],
          ),
          const SizedBox(height: 16),

          // Comment input with send button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'New comment…',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onSubmitted: _addComment,
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _addComment(_commentController.text),
              )
            ],
          ),
          const SizedBox(height: 16),

          // Comments list
          ...comments.map((c) => ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text(c.user,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(c.text),
                trailing: TextButton(
                    onPressed: () {}, child: Text('See profile')),
              )),
        ],
      ),
    );
  }
}

class _IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _IconLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

class Comment {
  final String user;
  final String text;
  Comment({required this.user, required this.text});
}