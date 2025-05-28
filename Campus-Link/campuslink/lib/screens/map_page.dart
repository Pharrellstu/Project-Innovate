import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/widgets/top_bar.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  final String title = "Map Page";

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  final List<String> _allItems = [
    'Apple',
    'Banana',
    'Grapes',
    'Orange',
    'Watermelon',
    'Peach',
    'Pineapple',
    'Mango',
    'Strawberry'
  ];

  String _searchText = '';

  // Controls the height of the bottom panel (as fraction of screen height)
  double _panelHeightFraction = 0.4;

  // To track drag gestures on the drag handle bar
  late double _dragStartY;
  late double _startHeightFraction;

  @override
  Widget build(BuildContext context) {
    final filteredItems = _allItems
        .where((item) =>
            item.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: TopBar(title: widget.title),
      body: Stack(
        children: [
          // Full screen map in background
          FlutterMap(
            options: MapOptions(
              center: LatLng(37.7749, -122.4194),
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
            ],
          ),

          // Search bar positioned just above the draggable list panel
          Positioned(
            left: 12,
            right: 12,
            bottom: _panelHeightFraction * screenHeight + 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
              ),
            ),
          ),

          // Draggable white panel with just the list, positioned at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _panelHeightFraction * screenHeight,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // The drag handle bar only - gesture detector attached here
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onVerticalDragStart: (details) {
                      _dragStartY = details.globalPosition.dy;
                      _startHeightFraction = _panelHeightFraction;
                    },
                    onVerticalDragUpdate: (details) {
                      double dragDelta = _dragStartY - details.globalPosition.dy;
                      double newHeight = _startHeightFraction + dragDelta / screenHeight;

                      // Clamp between min and max
                      if (newHeight > 0.85) newHeight = 0.85;
                      if (newHeight < 0.2) newHeight = 0.2;

                      setState(() {
                        _panelHeightFraction = newHeight;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 30,
                      alignment: Alignment.center,
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  // Divider line under drag bar
                  const Divider(height: 1),

                  // Expanded scrollable list
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (_, index) {
                        return ListTile(
                          title: Text(filteredItems[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}
