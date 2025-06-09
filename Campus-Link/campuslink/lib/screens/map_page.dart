import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/services/event_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  final String title = "Map Page";

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  double _panelHeightFraction = 0.1;
  late double _dragStartY;
  late double _startHeightFraction;

  late Future<List<Map<String, dynamic>>> _eventsFuture;

  LatLng? _currentLocation;

  String _dateFilter = 'All';
  String _categoryFilter = 'All';
  String _timeFilter = 'All';

  @override
  void initState() {
    super.initState();
    _eventsFuture = EventService.fetchEvents();

    _getCurrentLocation().then((loc) {
      setState(() {
        _currentLocation = loc;
      });
    });
  }

  Future<LatLng> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LatLng(52.785805, 6.897585);

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
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
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

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> events) {
    final now = DateTime.now();

    return events.where((event) {
      final eventDate = DateTime.tryParse(event['event_date'] ?? '');
      final eventTime = DateTime.tryParse(event['event_time'] ?? '');
      final category = event['category'];

      if (_dateFilter != 'All' && eventDate != null) {
        final diff = eventDate.difference(now).inDays;
        if ((_dateFilter == '1 Week' && (diff < 0 || diff > 7)) ||
            (_dateFilter == '2 Weeks' && (diff < 0 || diff > 14)) ||
            (_dateFilter == '1 Month' && (diff < 0 || diff > 30))) {
          return false;
        }
      }

      if (_categoryFilter != 'All' && category != _categoryFilter) return false;

      if (_timeFilter != 'All' && eventTime != null) {
        final hour = eventTime.hour;
        if (_timeFilter == 'Morning' && (hour < 6 || hour >= 12)) return false;
        if (_timeFilter == 'Afternoon' && (hour < 12 || hour >= 18)) return false;
        if (_timeFilter == 'Evening' && (hour < 18 || hour >= 24)) return false;
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
        title: const Text('Map View', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black)),
        actions: [
          IconButton(
            icon: Image.asset("resources/icons/filter.png", width: 24, height: 24),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Image.asset("resources/icons/newPostBtn.png"),
            onPressed: () => Navigator.pushNamed(context, '/create_event_page'),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: _currentLocation ?? LatLng(52.785805, 6.897585),
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.my_location, color: Colors.blue, size: 32),
                    ),
                  ],
                ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _eventsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final filteredEvents = _applyFilters(snapshot.data!);
                  return MarkerLayer(
                    markers: filteredEvents
                        .map((event) {
                          final lat = event['location_lat'];
                          final lng = event['location_lng'];
                          if (lat == null || lng == null) return null;
                          return Marker(
                            point: LatLng(lat, lng),
                            width: 36,
                            height: 36,
                            child: const Icon(Icons.location_pin, color: Colors.red, size: 36),
                          );
                        })
                        .whereType<Marker>()
                        .toList(),
                  );
                },
              ),
            ],
          ),

          Positioned(
            top: 100,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.blue),
              onPressed: () async {
                final loc = await _getCurrentLocation();
                setState(() {
                  _currentLocation = loc;
                });
              },
            ),
          ),

          Positioned(
            left: 12,
            right: 12,
            bottom: _panelHeightFraction * screenHeight + 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  suffixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _panelHeightFraction * screenHeight,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                      newHeight = newHeight.clamp(0.05, 0.9);
                      setState(() {
                        _panelHeightFraction = newHeight;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 6,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(3)),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _eventsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error loading events: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No events found.'));
                        }

                        final filteredEvents = _applyFilters(snapshot.data!);
                        if (filteredEvents.isEmpty) return const Center(child: Text('No events found.'));

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = filteredEvents[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    margin: const EdgeInsets.only(right: 16, top: 4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE0E0E0),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Image.asset('resources/icons/event_list_1.png', width: 16, height: 16),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      event['event_name'] ?? '',
                                                      style: const TextStyle(fontSize: 14),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Image.asset('resources/icons/event_list_2.png', width: 16, height: 16),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      event['category'] ?? '',
                                                      style: const TextStyle(fontSize: 14),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Image.asset('resources/icons/event_list_3.png', width: 16, height: 16),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      (event['event_date'] ?? '').toString().split(' ')[0],
                                                      style: const TextStyle(fontSize: 14),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Image.asset('resources/icons/event_list_4.png', width: 16, height: 16),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      event['location_name'] ?? '',
                                                      style: const TextStyle(fontSize: 14),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NavBar(),
          ),
        ],
      ),
    );
  }
}
