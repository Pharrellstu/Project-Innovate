// lib/screens/main_screen.dart
import 'package:campuslink/screens/chat_list_page.dart';
import 'package:flutter/material.dart';
import 'package:campuslink/screens/home_page.dart';
import 'package:campuslink/screens/map_page.dart';
import 'package:campuslink/screens/profile_page_update.dart';
import 'package:campuslink/widgets/nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Controller to manage the pages in the PageView.
  final PageController _pageController = PageController();
  // The index of the currently displayed page.
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Called when the page is changed in the PageView.
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// Called when a navigation bar item is tapped.
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
          ChatListPage(),
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
