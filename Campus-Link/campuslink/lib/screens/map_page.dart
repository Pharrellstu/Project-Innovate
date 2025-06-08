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
  double _panelHeightFraction = 0.05;
  late double _dragStartY;
  late double _startHeightFraction;

  late List<Map<String, dynamic>> _mockEvents;

  String _dateFilter = 'All';
  String _categoryFilter = 'All';
  String _timeFilter = 'All';

  @override
  void initState() {
    super.initState();
    _mockEvents = List.generate(10, (index) {
      return {
        'title': 'Event ${index + 1}',
        'date': DateTime.now().add(Duration(days: index * 3)),
        'category': index % 3 == 0
            ? 'Music'
            : index % 3 == 1
                ? 'Sports'
                : 'Food',
        'timeOfDay': index % 3 == 0
            ? 'Morning'
            : index % 3 == 1
                ? 'Afternoon'
                : 'Evening',
      };
    });
  }

  Future<LatLng> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LatLng(52.785805, 6.897585); // fallback

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return LatLng(52.785805, 6.897585);
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  void _showFilterDialog() {
    String tempDateFilter = _dateFilter;
    String tempCategoryFilter = _categoryFilter;
    String tempTimeFilter = _timeFilter;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Events'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                height: 280,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date Range'),
                      ...['All', '1 Week', '2 Weeks', '1 Month'].map((value) {
                        return RadioListTile<String>(
                          title: Text(value),
                          value: value,
                          groupValue: tempDateFilter,
                          onChanged: (val) {
                            setState(() {
                              tempDateFilter = val!;
                            });
                          },
                        );
                      }),
                      const SizedBox(height: 8),
                      const Text('Category'),
                      ...['All', 'Music', 'Sports', 'Food'].map((value) {
                        return RadioListTile<String>(
                          title: Text(value),
                          value: value,
                          groupValue: tempCategoryFilter,
                          onChanged: (val) {
                            setState(() {
                              tempCategoryFilter = val!;
                            });
                          },
                        );
                      }),
                      const SizedBox(height: 8),
                      const Text('Time of Day'),
                      ...['All', 'Morning', 'Afternoon', 'Evening'].map((value) {
                        return RadioListTile<String>(
                          title: Text(value),
                          value: value,
                          groupValue: tempTimeFilter,
                          onChanged: (val) {
                            setState(() {
                              tempTimeFilter = val!;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _dateFilter = tempDateFilter;
                  _categoryFilter = tempCategoryFilter;
                  _timeFilter = tempTimeFilter;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> get _filteredEvents {
    DateTime now = DateTime.now();

    return _mockEvents.where((event) {
      // Date filter
      if (_dateFilter != 'All') {
        final diff = event['date'].difference(now).inDays;
        switch (_dateFilter) {
          case '1 Week':
            if (diff > 7) return false;
            break;
          case '2 Weeks':
            if (diff > 14) return false;
            break;
          case '1 Month':
            if (diff > 30) return false;
            break;
        }
      }

      // Category filter
      if (_categoryFilter != 'All' && event['category'] != _categoryFilter) {
        return false;
      }

      // Time of day filter
      if (_timeFilter != 'All' && event['timeOfDay'] != _timeFilter) {
        return false;
      }

      return true;
    }).toList();
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
            onPressed: _showFilterDialog,
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
                onChanged: (value) {
                  // Implement search filtering if needed
                },
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
                      itemCount: _filteredEvents.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final event = _filteredEvents[index];
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
                                            event['title'],
                                            iconColor: Colors.blue,
                                            textColor: Colors.black,
                                          ),
                                        ),
                                        Expanded(
                                          child: _iconText(
                                            'resources/icons/person.png',
                                            event['category'],
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
                                            '${event['date'].day}/${event['date'].month}/${event['date'].year}',
                                            iconColor: Colors.blue,
                                            textColor: Colors.grey,
                                          ),
                                        ),
                                        Expanded(
                                          child: _iconText(
                                            'resources/icons/pin.png',
                                            event['timeOfDay'],
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

  Widget _iconText(String assetPath, String text,
      {Color iconColor = Colors.black, Color textColor = Colors.black}) {
    return Row(
      children: [
        Image.asset(assetPath, width: 16, height: 16, color: iconColor),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: TextStyle(fontSize: 14, color: textColor))),
      ],
    );
  }
}
