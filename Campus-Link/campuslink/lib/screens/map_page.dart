// map_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/models/event.dart';
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

  late Future<List<EventModel>> _eventsFuture;

  String _dateFilter = 'All';
  String _categoryFilter = 'All';
  String _timeFilter = 'All';

  @override
  void initState() {
    super.initState();
    _eventsFuture = EventService.fetchEvents();
  }

  Future<LatLng> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LatLng(52.785805, 6.897585);

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

  List<EventModel> _applyFilters(List<EventModel> events) {
    DateTime now = DateTime.now();

    return events.where((event) {
      if (_dateFilter != 'All' && event.eventDate != null) {
        final diff = event.eventDate!.difference(now).inDays;
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

      if (_categoryFilter != 'All' && event.category != _categoryFilter) {
        return false;
      }

      if (_timeFilter != 'All' && event.eventTime != null) {
        final time = DateTime.tryParse(event.eventTime!);
        if (time == null) return false;
        if (_timeFilter == 'Morning' && time.hour >= 12) return false;
        if (_timeFilter == 'Afternoon' && (time.hour < 12 || time.hour >= 18)) return false;
        if (_timeFilter == 'Evening' && time.hour < 18) return false;
      }

      return true;
    }).toList();
  }

  Widget buildEventRow(String imagePath, String text) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.only(right: 10),
          decoration: const BoxDecoration(
            color: Color(0xFFE0E0E0),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Image.asset(
              imagePath,
              width: 16,
              height: 16,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
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
                  FutureBuilder<List<EventModel>>(
                    future: _eventsFuture,
                    builder: (context, eventSnapshot) {
                      if (!eventSnapshot.hasData) return const SizedBox();
                      final filteredEvents = _applyFilters(eventSnapshot.data!);
                      return MarkerLayer(
                        markers: filteredEvents
                            .where((event) => event.locationLat != null && event.locationLng != null)
                            .map((event) => Marker(
                                  point: LatLng(event.locationLat!, event.locationLng!),
                                  width: 36,
                                  height: 36,
                                  child: const Icon(Icons.location_pin, color: Colors.red, size: 36),
                                ))
                            .toList(),
                      );
                    },
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
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
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

          // Bottom sliding panel
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
                    child: FutureBuilder<List<EventModel>>(
                      future: _eventsFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
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
                                  // Large light gray circle on the left
                                  Container(
                                    width: 50,
                                    height: 50,
                                    margin: const EdgeInsets.only(right: 16, top: 4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE0E0E0),
                                      shape: BoxShape.circle,
                                    ),
                                  ),

                                  // 2x2 grid of icon + text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                    'resources/icons/event_list_1.png',
                                                    width: 16,
                                                    height: 16,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      event.eventName ?? '',
                                                      style: const TextStyle(fontSize: 14),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                    'resources/icons/event_list_2.png',
                                                    width: 16,
                                                    height: 16,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      event.category ?? '',
                                                      style: const TextStyle(fontSize: 14),
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
                                                  Image.asset(
                                                    'resources/icons/event_list_3.png',
                                                    width: 16,
                                                    height: 16,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      event.eventDate?.toLocal().toString().split(' ')[0] ?? '',
                                                      style: const TextStyle(fontSize: 14),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                    'resources/icons/event_list_4.png',
                                                    width: 16,
                                                    height: 16,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      event.locationName ?? '',
                                                      style: const TextStyle(fontSize: 14),
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

          // Bottom Nav Bar
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
