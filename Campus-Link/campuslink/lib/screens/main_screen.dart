// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:campuslink/screens/home_page.dart';
import 'package:campuslink/screens/map_page.dart';
import 'package:campuslink/screens/chat_list.dart';
import 'package:campuslink/screens/profile_page_update.dart';
import 'package:campuslink/widgets/nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const <Widget>[
          HomePage(),
          MapPage(),
          ChatList(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: NavBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
}