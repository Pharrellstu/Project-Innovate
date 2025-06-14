import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/services/event_service.dart';
import 'package:campuslink/models/event.dart';
import 'package:intl/intl.dart'; // Import for parsing time strings

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

  // Initialize filters to 'All' to ensure nothing is filtered by default
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
    if (!serviceEnabled) {
      print('Location services are disabled.');
      // Fallback to a default location if services are disabled
      return LatLng(52.785805, 6.897585);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        print('Location permissions are denied or permanently denied.');
        // Fallback to a default location if permissions are denied
        return LatLng(52.785805, 6.897585);
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high, // Increased accuracy
        timeLimit: const Duration(seconds: 10), // Add a time limit
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting current location: $e');
      // Fallback to a default location on error
      return LatLng(52.785805, 6.897585);
    }
  }

  void _showFilterDialog() {
    // Use temporary variables for dialog selection to avoid updating state until 'Apply' is pressed
    String tempDateFilter = _dateFilter;
    String tempCategoryFilter = _categoryFilter;
    String tempTimeFilter = _timeFilter;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Events'),
          content: StatefulBuilder( // Use StatefulBuilder to update dialog content
            builder: (context, setState) {
              return SizedBox(
                height: 280, // Adjust height as needed
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
                      // Add your actual categories here. Example:
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
                setState(() { // Update the main page's state
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
    final now = DateTime.now();

    return events.where((event) {
      final eventDate = event.eventDate;
      final eventTimeString = event.eventTime;
      final category = event.category;

      bool keepEvent = true; // Assume we keep it unless a filter condition makes it false

      // --- Date Filter ---
      if (_dateFilter != 'All') {
        if (eventDate == null) {
          // If a date filter is active but event has no date, exclude it
          print('Filtering out event "${event.eventName}" by Date: eventDate is null but filter is $_dateFilter');
          keepEvent = false;
        } else {
          final diff = eventDate.difference(now).inDays;
          if ((_dateFilter == '1 Week' && (diff < 0 || diff > 7)) ||
              (_dateFilter == '2 Weeks' && (diff < 0 || diff > 14)) ||
              (_dateFilter == '1 Month' && (diff < 0 || diff > 30))) {
            print('Filtering out event "${event.eventName}" by Date: $eventDate (diff=$diff, filter: $_dateFilter)');
            keepEvent = false;
          }
        }
      }

      // --- Category Filter ---
      if (keepEvent && _categoryFilter != 'All') { // Only apply if not already filtered
        if (category == null || category != _categoryFilter) {
          print('Filtering out event "${event.eventName}" by Category: $category (filter: $_categoryFilter)');
          keepEvent = false;
        }
      }

      // --- Time Filter ---
      if (keepEvent && _timeFilter != 'All') { // Only apply if not already filtered
        if (eventTimeString == null) {
          // If a time filter is active but event has no time, exclude it
          print('Filtering out event "${event.eventName}" by Time: eventTime is null but filter is $_timeFilter');
          keepEvent = false;
        } else {
          try {
            final parsedTime = DateFormat('HH:mm').parse(eventTimeString);
            final hour = parsedTime.hour;
            if ((_timeFilter == 'Morning' && (hour < 6 || hour >= 12)) ||
                (_timeFilter == 'Afternoon' && (hour < 12 || hour >= 18)) ||
                (_timeFilter == 'Evening' && (hour < 18 || hour >= 24))) {
              print('Filtering out event "${event.eventName}" by Time: $eventTimeString (hour=$hour, filter: $_timeFilter)');
              keepEvent = false;
            }
          } catch (e) {
            print('Error parsing event time for "${event.eventName}": $eventTimeString - $e');
            keepEvent = false; // Exclude events with unparsable time
          }
        }
      }

      if (!keepEvent) {
        return false; // This event was filtered out by one of the conditions
      }
      return true; // This event passed all active filters
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
            options: MapOptions(
              center: _currentLocation ?? LatLng(52.785805, 6.897585), // Default to a central location if _currentLocation is null
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              if (_currentLocation != null) // Only show current location marker if available
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Show loading indicator
                  }
                  if (snapshot.hasError) {
                    print('Error fetching events: ${snapshot.error}'); // Log error
                    return Center(child: Text('Error loading events: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox(); // No data for map markers
                  }

                  // Print before and after filtering to debug list emptiness
                  print('Total events fetched for map: ${snapshot.data!.length}');
                  final filteredEventsForMap = _applyFilters(snapshot.data!); // Apply filters for map markers too
                  print('Events after filtering for map: ${filteredEventsForMap.length}');

                  return MarkerLayer(
                    markers: filteredEventsForMap
                        .map((event) {
                          final lat = event.locationLat;
                          final lng = event.locationLng;
                          if (lat == null || lng == null) return null; // Only show marker if location is valid
                          return Marker(
                            point: LatLng(lat, lng),
                            width: 36,
                            height: 36,
                            child: const Icon(Icons.location_pin, color: Colors.red, size: 36),
                          );
                        })
                        .whereType<Marker>() // Remove any null markers
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
            // Adjust position based on panel height, leaving some padding at the bottom
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
              ),
              child: Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent, // Allows drag on transparent parts
                    onVerticalDragStart: (details) {
                      _dragStartY = details.globalPosition.dy;
                      _startHeightFraction = _panelHeightFraction;
                    },
                    onVerticalDragUpdate: (details) {
                      double dragDelta = _dragStartY - details.globalPosition.dy;
                      double newHeight = _startHeightFraction + dragDelta / screenHeight;
                      newHeight = newHeight.clamp(0.05, 0.9); // Clamp height between 5% and 90%
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
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          print('Error loading events for list: ${snapshot.error}'); // Log error
                          return Center(child: Text('Error loading events: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No events found.'));
                        }

                        // Apply filters to the list of events
                        print('Current Filters in List View: Date=$_dateFilter, Category=$_categoryFilter, Time=$_timeFilter');
                        print('Total events fetched for list: ${snapshot.data!.length}');
                        final filteredEvents = _applyFilters(snapshot.data!);
                        print('Events after filtering for list: ${filteredEvents.length}');


                        if (filteredEvents.isEmpty) {
                          return const Center(child: Text('No events found matching current filters.'));
                        }

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
                                      color: Color(0xFFE0E0E0), // Placeholder for event image
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.event, color: Colors.grey), // Example icon
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Row 1: Event Name & Category
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Image.asset('resources/icons/event_list_1.png', width: 16, height: 16),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      event.eventName.isNotEmpty ? event.eventName : 'Unnamed Event', // Ensure non-empty display
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
                                                      event.category ?? 'No Category', // Default for nullable category
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
                                        // Row 2: Event Date & Location Name
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Image.asset('resources/icons/event_list_3.png', width: 16, height: 16),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      event.eventDate != null
                                                          ? DateFormat('MMM d, yyyy').format(event.eventDate!) // Format date nicely
                                                          : 'No Date', // Default for nullable eventDate
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
                                                      event.locationName ?? 'Unknown Location', // Default for nullable locationName
                                                      style: const TextStyle(fontSize: 14),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Optional: Add Event Time row if needed
                                        if (event.eventTime != null && event.eventTime!.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Row(
                                              children: [
                                                Icon(Icons.access_time, size: 16), // Example icon for time
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

          // Navbar (position based on current context)
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