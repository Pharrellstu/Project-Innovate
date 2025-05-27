import 'package:flutter/material.dart';
import 'package:campuslink/widgets/nav_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  final String title = "Explore Page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}