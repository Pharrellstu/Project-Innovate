import 'package:flutter/material.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/widgets/top_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  final String title = "Explore Page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: title,),
      bottomNavigationBar: NavBar(),
    );
  }
}