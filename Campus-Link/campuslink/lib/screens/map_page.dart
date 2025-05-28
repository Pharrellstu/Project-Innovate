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

class SimpleSearchBar extends StatefulWidget {
  @override
  _SimpleSearchBarState createState() => _SimpleSearchBarState();
}

class _SimpleSearchBarState extends State<SimpleSearchBar> {
  final List<String> _allItems = [
    'Apple',
    'Banana',
    'Grapes',
    'Orange',
    'Watermelon'
  ];
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    final filteredItems = _allItems
        .where((item) => item.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('Search Example')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (_, index) => ListTile(
                title: Text(filteredItems[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


