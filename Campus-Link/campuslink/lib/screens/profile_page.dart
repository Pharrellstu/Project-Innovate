import 'package:flutter/material.dart';
import 'package:campuslink/widgets/nav_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  final String title = "Profile Page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Text(
          'Profile Page Content',
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}