import 'package:flutter/material.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/widgets/top_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  final String title = "Profile Page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: title,),
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