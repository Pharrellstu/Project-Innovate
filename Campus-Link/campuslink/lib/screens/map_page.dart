import 'package:flutter/material.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/widgets/top_bar.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});
  final String title = "Map Page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: title),
      body: Center(
        child: Text('Map Page Content', style: TextStyle(fontSize: 24)),
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}
