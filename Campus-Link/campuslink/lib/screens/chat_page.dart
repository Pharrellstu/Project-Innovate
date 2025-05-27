import 'package:flutter/material.dart';
import 'package:campuslink/widgets/nav_bar.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});
  final String title = "Chat Page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Text(
          'Chat Page Content',
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}