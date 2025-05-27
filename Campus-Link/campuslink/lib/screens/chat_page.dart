import 'package:flutter/material.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/widgets/top_bar.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});
  final String title = "Chat Page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: title),
      body: Center(
        child: Text('Chat Page Content', style: TextStyle(fontSize: 24)),
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}
