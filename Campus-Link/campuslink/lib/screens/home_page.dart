import 'package:campuslink/widgets/interestingPeople.dart';
import 'package:flutter/material.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/widgets/top_bar.dart';
import 'package:campuslink/widgets/feed.dart';
import 'package:campuslink/widgets/explore.dart';

import '../widgets/accounts_page.dart'; // Create this later

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TopBar(title: 'HomePage', isCreateBtnVisible: true, isLogoutBtnVisible: false),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Explore'),
            Tab(text: 'Accounts'),
          ],
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: const [
          ExploreScreen(),
          AccountsPage(), // Our new accounts page
        ],
      ),
    );
  }
}