import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:campuslink/widgets/nav_bar.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  final String title = "Map Page";

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  double _panelHeightFraction = 0.4;
  late double _dragStartY;
  late double _startHeightFraction;
  final List<Map<String, dynamic>> _mockEvents = List.generate(10, (_) => {});

  Future<LatLng> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LatLng(52.785805, 6.897585); // fallback

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return LatLng(52.785805, 6.897585);
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Map View',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Image.asset("resources/icons/filter.png", width: 24, height: 24),
            onPressed: () {},
          ),
          IconButton(
            icon: Image.asset("resources/icons/newPostBtn.png"),
            onPressed: () {
              Navigator.pushNamed(context, '/create_event_page');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<LatLng>(
            future: _getCurrentLocation(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              return FlutterMap(
                options: MapOptions(
                  center: snapshot.data!,
                  zoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                ],
              );
            },
          ),

          // Search bar
          Positioned(
            left: 12,
            right: 12,
            bottom: _panelHeightFraction * screenHeight + 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  suffixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Draggable bottom panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _panelHeightFraction * screenHeight,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2))],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onVerticalDragStart: (details) {
                      _dragStartY = details.globalPosition.dy;
                      _startHeightFraction = _panelHeightFraction;
                    },
                    onVerticalDragUpdate: (details) {
                      double dragDelta = _dragStartY - details.globalPosition.dy;
                      double newHeight = _startHeightFraction + dragDelta / screenHeight;
                      setState(() {
                        _panelHeightFraction = newHeight.clamp(0.2, 0.85);
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      alignment: Alignment.center,
                      child: Container(
                        width: 60,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  // Events list
                  Expanded(
                    child: ListView.builder(
                      itemCount: _mockEvents.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                margin: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: _iconText(
                                            'resources/icons/lightbulb.png',
                                            'Pub Quiz',
                                            iconColor: Colors.blue,
                                            textColor: Colors.black,
                                          ),
                                        ),
                                        Expanded(
                                          child: _iconText(
                                            'resources/icons/person.png',
                                            'Think Wireless',
                                            iconColor: Colors.blue,
                                            textColor: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: _iconText(
                                            'resources/icons/agenda.png',
                                            '14/5/2024',
                                            iconColor: Colors.blue,
                                            textColor: Colors.grey,
                                          ),
                                        ),
                                        Expanded(
                                          child: _iconText(
                                            'resources/icons/pin.png',
                                            'Bar Hop',
                                            iconColor: Colors.blue,
                                            textColor: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
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

  Widget _iconText(String assetPath, String text, {Color iconColor = Colors.black, Color textColor = Colors.black}) {
    return Row(
      children: [
        Image.asset(assetPath, width: 16, height: 16, color: iconColor),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: TextStyle(fontSize: 14, color: textColor))),
      ],
    );
  }
}
