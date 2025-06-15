import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/services/event_service.dart';
import 'package:campuslink/models/event.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui; // <--- ADDED THIS IMPORT WITH A PREFIX

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

  LatLng? _currentLocation;

  String _dateFilter = 'All';
  String _categoryFilter = 'All';
  String _timeFilter = 'All';

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    debugPrint('[MapPage] initState called. Time: ${DateTime.now()}');
    _eventsFuture = EventService.fetchEvents();

    _getCurrentLocation().then((loc) {
      if (mounted) {
        setState(() {
          _currentLocation = loc;
          _mapController.move(loc, _mapController.zoom);
        });
        debugPrint('[MapPage] Current location updated and map moved. Time: ${DateTime.now()}');
      }
    }).catchError((e) {
      debugPrint('[MapPage] Error getting current location during initState: $e. Time: ${DateTime.now()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get current location: $e')),
        );
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    debugPrint('[MapPage] dispose called. Time: ${DateTime.now()}');
    super.dispose();
  }

  Future<LatLng> _getCurrentLocation() async {
    debugPrint('[_getCurrentLocation] Attempting to get location. Time: ${DateTime.now()}');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled. Returning default. Time: ${DateTime.now()}');
      return LatLng(52.785805, 6.897585); // Default: Campus location
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are denied or permanently denied. Returning default. Time: ${DateTime.now()}');
        return LatLng(52.785805, 6.897585); // Default: Campus location
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      debugPrint('Current location fetched: ${position.latitude}, ${position.longitude}. Time: ${DateTime.now()}');
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error getting current location: $e. Returning default. Time: ${DateTime.now()}');
      return LatLng(52.785805, 6.897585); // Default: Campus location
    }
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
                height: MediaQuery.of(context).size.height * 0.5,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...['All', 'Music', 'Sports', 'Food', 'Academics', 'Social', 'Workshop', 'Conference'].map((value) {
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
                      const Text('Time of Day', style: TextStyle(fontWeight: FontWeight.bold)),
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
                if (mounted) {
                  setState(() {
                    _dateFilter = tempDateFilter;
                    _categoryFilter = tempCategoryFilter;
                    _timeFilter = tempTimeFilter;
                    _eventsFuture = EventService.fetchEvents(); // Re-fetch to apply new filters
                    debugPrint('[MapPage] Filters applied and events future reset. Time: ${DateTime.now()}');
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  static List<EventModel> _applyFiltersStatic(Map<String, dynamic> args) {
    final List<EventModel> events = args['events'];
    final String dateFilter = args['dateFilter'];
    final String categoryFilter = args['categoryFilter'];
    final String timeFilter = args['timeFilter'];

    final now = DateTime.now();

    debugPrint('[_applyFiltersStatic] Start filtering. Total events: ${events.length}. Time: ${DateTime.now()}');

    final filteredList = events.where((event) {
      bool keepEvent = true;

      // --- Date Filter ---
      if (dateFilter != 'All') {
        if (event.eventDate == null) {
          keepEvent = false;
        } else {
          final diff = event.eventDate!.difference(now);
          if (diff.isNegative) { // Event is in the past
            keepEvent = false;
          } else {
            final diffInDays = diff.inDays;
            if ((dateFilter == '1 Week' && diffInDays > 7) ||
                (dateFilter == '2 Weeks' && diffInDays > 14) ||
                (dateFilter == '1 Month' && diffInDays > 30)) {
              keepEvent = false;
            }
          }
        }
      }

      // --- Category Filter ---
      if (keepEvent && categoryFilter != 'All') {
        if (event.category == null || event.category!.toLowerCase() != categoryFilter.toLowerCase()) {
          keepEvent = false;
        }
      }

      // --- Time Filter ---
      if (keepEvent && timeFilter != 'All') {
        if (event.eventTime == null || event.eventTime!.isEmpty) {
          keepEvent = false;
        } else {
          try {
            final parsedTime = DateFormat('HH:mm').parse(event.eventTime!);
            final hour = parsedTime.hour;
            if ((timeFilter == 'Morning' && (hour < 6 || hour >= 12)) ||
                (timeFilter == 'Afternoon' && (hour < 12 || hour >= 18)) ||
                (timeFilter == 'Evening' && (hour < 18 || hour >= 24))) {
              keepEvent = false;
            }
          } catch (e) {
            debugPrint('Error parsing event time for "${event.eventName}" in background: ${event.eventTime} - $e');
            keepEvent = false;
          }
        }
      }
      return keepEvent;
    }).toList();

    debugPrint('[_applyFiltersStatic] Finished filtering. Filtered events: ${filteredList.length}. Time: ${DateTime.now()}');
    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    debugPrint('[MapPage] Building widget tree. Time: ${DateTime.now()}');

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
            onPressed: () => Navigator.pushNamed(context, '/create_event_page'),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentLocation ?? LatLng(52.785805, 6.897585),
              zoom: 13.0,
              onTap: (tapPos, latLng) {
                debugPrint('Map tapped at: $latLng. Time: ${DateTime.now()}');
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
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
              FutureBuilder<List<EventModel>>(
                future: _eventsFuture,
                builder: (context, snapshot) {
                  debugPrint('[Map Markers FutureBuilder] Connection state: ${snapshot.connectionState}. Time: ${DateTime.now()}');
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  if (snapshot.hasError) {
                    debugPrint('Error fetching events for map: ${snapshot.error}. Time: ${DateTime.now()}');
                    return const SizedBox.shrink();
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    debugPrint('No events data for map or data is empty. Time: ${DateTime.now()}');
                    return const SizedBox.shrink();
                  }

                  final allEvents = snapshot.data!;
                  return FutureBuilder<List<EventModel>>(
                    future: compute(_applyFiltersStatic, {
                      'events': allEvents,
                      'dateFilter': _dateFilter,
                      'categoryFilter': _categoryFilter,
                      'timeFilter': _timeFilter,
                    }),
                    builder: (context, filteredSnapshot) {
                      debugPrint('[Map Markers Filtered FutureBuilder] Connection state: ${filteredSnapshot.connectionState}. Time: ${DateTime.now()}');
                      if (filteredSnapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox.shrink();
                      }
                      if (filteredSnapshot.hasError) {
                        debugPrint('Error filtering events for map in background: ${filteredSnapshot.error}. Time: ${DateTime.now()}');
                        return const SizedBox.shrink();
                      }
                      if (!filteredSnapshot.hasData || filteredSnapshot.data!.isEmpty) {
                        debugPrint('No filtered events data for map. Time: ${DateTime.now()}');
                        return const SizedBox.shrink();
                      }

                      final filteredEventsForMap = filteredSnapshot.data!;
                      debugPrint('Events after background filtering for map: ${filteredEventsForMap.length}. Time: ${DateTime.now()}');

                      return MarkerLayer(
                        markers: filteredEventsForMap
                            .map((event) {
                              final lat = event.locationLat;
                              final lng = event.locationLng;
                              if (lat == null || lng == null) {
                                debugPrint('Skipping marker for event "${event.eventName}" due to null coordinates. Time: ${DateTime.now()}');
                                return null;
                              }
                              return Marker(
                                point: LatLng(lat, lng),
                                width: 50, // Adjust width/height as needed for the overall marker size
                                height: 60, // Marker height should be slightly taller for the pin
                                child: EventMarker( // Using your new custom widget here!
                                  imagePath: 'resources/img/PubQuiz.png', // Corrected path. Ensure this exists and is correct!
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Tapped on ${event.eventName}')),
                                    );
                                  },
                                ),
                              );
                            })
                            .whereType<Marker>()
                            .toList(),
                      );
                    },
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
                debugPrint('[MapPage] My Location button pressed. Time: ${DateTime.now()}');
                final loc = await _getCurrentLocation();
                if (mounted) {
                  setState(() {
                    _currentLocation = loc;
                    _mapController.move(loc, _mapController.zoom);
                  });
                }
              },
            ),
          ),

          Positioned(
            left: 12,
            right: 12,
            bottom: (_panelHeightFraction * screenHeight) + 12,
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
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2))],
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
                      newHeight = newHeight.clamp(0.1, 0.9);
                      if (mounted) {
                        setState(() {
                          _panelHeightFraction = newHeight;
                        });
                      }
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
                        debugPrint('[Event List FutureBuilder] Connection state: ${snapshot.connectionState}. Time: ${DateTime.now()}');
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          debugPrint('Error loading events for list: ${snapshot.error}. Time: ${DateTime.now()}');
                          return Center(child: Text('Error loading events: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          debugPrint('No events data for list or data is empty. Time: ${DateTime.now()}');
                          return const Center(child: Text('No events found.'));
                        }

                        final allEvents = snapshot.data!;
                        return FutureBuilder<List<EventModel>>(
                          future: compute(_applyFiltersStatic, {
                            'events': allEvents,
                            'dateFilter': _dateFilter,
                            'categoryFilter': _categoryFilter,
                            'timeFilter': _timeFilter,
                          }),
                          builder: (context, filteredSnapshot) {
                            debugPrint('[Event List Filtered FutureBuilder] Connection state: ${filteredSnapshot.connectionState}. Time: ${DateTime.now()}');
                            if (filteredSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (filteredSnapshot.hasError) {
                              debugPrint('Error filtering events for list in background: ${filteredSnapshot.error}. Time: ${DateTime.now()}');
                              return Center(child: Text('Error filtering events: ${filteredSnapshot.error}'));
                            }
                            if (!filteredSnapshot.hasData || filteredSnapshot.data!.isEmpty) {
                              debugPrint('No filtered events data for list. Time: ${DateTime.now()}');
                              return const Center(child: Text('No events found matching current filters.'));
                            }

                            final filteredEvents = filteredSnapshot.data!;
                            debugPrint('Events after background filtering for list: ${filteredEvents.length}. Time: ${DateTime.now()}');

                            if (filteredEvents.isEmpty) {
                              return const Center(child: Text('No events found matching current filters.'));
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: filteredEvents.length,
                              itemBuilder: (context, index) {
                                final event = filteredEvents[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  child: InkWell(
                                    onTap: () {
                                      debugPrint('Tapped on event: ${event.eventName}. Time: ${DateTime.now()}');
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            margin: const EdgeInsets.only(right: 16, top: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE0E0E0),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.grey[300]!, width: 1),
                                            ),
                                            child: ClipOval(
                                              child: Image.asset(
                                                'resources/img/PubQuiz.png', // Corrected path
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Icon(
                                                    Icons.error_outline,
                                                    color: Colors.red,
                                                    size: 28,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Image.asset('resources/icons/event_list_1.png', width: 16, height: 16),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        event.eventName.isNotEmpty ? event.eventName : 'Unnamed Event',
                                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    Image.asset('resources/icons/event_list_2.png', width: 16, height: 16),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        event.category ?? 'No Category',
                                                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Image.asset('resources/icons/event_list_3.png', width: 16, height: 16),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        event.eventDate != null
                                                            ? DateFormat('MMM d,yyyy').format(event.eventDate!)
                                                            : 'No Date',
                                                        style: const TextStyle(fontSize: 14),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    Image.asset('resources/icons/event_list_4.png', width: 16, height: 16),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        event.locationName ?? 'Unknown Location',
                                                        style: const TextStyle(fontSize: 14),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (event.eventTime != null && event.eventTime!.isNotEmpty)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 8.0),
                                                    child: Row(
                                                      children: [
                                                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                                        const SizedBox(width: 6),
                                                        Text(
                                                          event.eventTime!,
                                                          style: const TextStyle(fontSize: 14),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
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


// --- Custom Event Marker Widget ---
class EventMarker extends StatelessWidget {
  final String imagePath; // Path to your event image (e.g., 'resources/img/PubQuiz.png')
  final VoidCallback onTap; // What happens when the marker is tapped

  const EventMarker({
    super.key,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The Pin Shape (e.g., a custom painter or a rotated container)
          // For simplicity, let's start with a Stack of a white circle and a red triangle
          Positioned(
            bottom: 0, // Align the pin's base to the marker's point
            child: Container(
              width: 30, // Adjust size as needed
              height: 30, // Adjust size as needed
              decoration: BoxDecoration(
                color: Colors.red[700], // Marker base color
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          Positioned(
            bottom: -5, // Adjust this to make the triangle overlap the circle nicely
            child: CustomPaint(
              size: const Size(20, 20), // Size of the triangle
              painter: _TrianglePainter(Colors.red[700]!), // Same color as the base
            ),
          ),

          // The Image (your PubQuiz.png)
          Container(
            width: 32, // Size of the image circle
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white, // Background for the image
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 1), // Optional border
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover, // Ensures the image fills the circle
                errorBuilder: (context, error, stackTrace) {
                  // Fallback for when the image fails to load
                  return const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 28,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Custom Painter for the Triangle Part of the Marker ---
class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path(); // <--- Corrected: Using ui.Path()
    path.moveTo(size.width / 2, size.height); // Bottom point
    path.lineTo(0, 0); // Top-left point
    path.lineTo(size.width, 0); // Top-right point
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}