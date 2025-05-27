import 'package:flutter/material.dart';
import 'package:campuslink/widgets/nav_bar.dart';
class MapPage extends StatelessWidget {
  const MapPage({super.key});
  final String title = "Map Page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Text(
          'Map Page Content',
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}