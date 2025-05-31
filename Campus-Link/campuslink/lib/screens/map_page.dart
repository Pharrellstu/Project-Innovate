import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/widgets/top_bar.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  final String title = "Map Page";

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
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
  double _panelHeightFraction = 0.4;
  late double _dragStartY;
  late double _startHeightFraction;

  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  /// Fetch the user's location using the `location` package
  Future<void> _getUserLocation() async {
    final location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final locData = await location.getLocation();
    setState(() {
      _userLocation = LatLng(locData.latitude!, locData.longitude!);
    });
  }

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
          // Background map
          FlutterMap(
            options: MapOptions(
              center: _userLocation ?? LatLng(37.7749, -122.4194), // fallback
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      width: 80,
                      height: 80,
                      builder: (ctx) => const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Search bar positioned above the draggable panel
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

          // Draggable bottom list panel
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
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drag handle bar
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onVerticalDragStart: (details) {
                      _dragStartY = details.globalPosition.dy;
                      _startHeightFraction = _panelHeightFraction;
                    },
                    onVerticalDragUpdate: (details) {
                      double dragDelta =
                          _dragStartY - details.globalPosition.dy;
                      double newHeight =
                          _startHeightFraction + dragDelta / screenHeight;

                      // Clamp height between 20% and 85% of screen
                      newHeight = newHeight.clamp(0.2, 0.85);

                      setState(() {
                        _panelHeightFraction = newHeight;
                      });
                    },
                    child: Container(
                      width: double.infinity,
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

                  const Divider(height: 1),

                  // Filtered scrollable list
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
