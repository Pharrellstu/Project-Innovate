import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/services/event_service.dart';
import 'package:campuslink/models/event.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui; // Explicitly import dart:ui and alias it
import 'dart:async'; // Required for Timer

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

  // --- New additions for highlight and scroll ---
  final Map<String, GlobalKey> _eventItemKeys = {}; // Map to store GlobalKeys for each event card by its ID
  String? _highlightedEventId; // Stores the ID of the currently highlighted event
  Timer? _highlightTimer; // Timer to control the highlight duration
  // --- End new additions ---

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
    _highlightTimer?.cancel(); // Cancel the timer to prevent memory leaks
    debugPrint('[MapPage] dispose called. Time: ${DateTime.now()}');
    super.dispose();
  }

  Future<LatLng> _getCurrentLocation() async {
    debugPrint('[_getCurrentLocation] Attempting to get location. Time: ${DateTime.now()}');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled. Returning default. Time: ${DateTime.now()}');
      return LatLng(52.785805, 6.897585); // Default: Campus location (Erica, Drenthe, Netherlands)
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are denied or permanently denied. Returning default. Time: ${DateTime.now()}');
        return LatLng(52.785805, 6.897585); // Default: Campus location (Erica, Drenthe, Netherlands)
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
      return LatLng(52.785805, 6.897585); // Default: Campus location (Erica, Drenthe, Netherlands)
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

  // In lib/screens/map_page.dart

// ... (rest of your imports and class definition)

  static List<EventModel> _applyFiltersStatic(Map<String, dynamic> args) {
    final List<EventModel> events = args['events'];
    final String dateFilter = args['dateFilter'];
    final String categoryFilter = args['categoryFilter'];
    final String timeFilter = args['timeFilter'];

    final now = DateTime.now();

    debugPrint('--- Filtering Started ---');
    debugPrint('Current Date: $now');
    debugPrint('Active Filters: Date="$dateFilter", Category="$categoryFilter", Time="$timeFilter"');
    debugPrint('Total events received for filtering: ${events.length}');

    final filteredList = events.where((event) {
      bool keepEvent = true;
      debugPrint('\nProcessing Event: "${event.eventName}" (ID: ${event.id})');
      debugPrint('  Event Data: Date=${event.eventDate}, Category=${event.category}, Time=${event.eventTime}, Lat=${event.locationLat}, Lng=${event.locationLng}');


      // --- Date Filter ---
      if (dateFilter != 'All') {
        debugPrint('  Applying Date Filter ($dateFilter)...');
        if (event.eventDate == null) {
          keepEvent = false;
          debugPrint('    - Date Filter: Event "${event.eventName}" removed because eventDate is null.');
        } else {
          final diff = event.eventDate!.difference(now);
          if (diff.isNegative) { // Event is in the past
            keepEvent = false;
            debugPrint('    - Date Filter: Event "${event.eventName}" removed because it is in the past (diff: $diff).');
          } else {
            final diffInDays = diff.inDays;
            if ((dateFilter == '1 Week' && diffInDays > 7)) {
              keepEvent = false;
              debugPrint('    - Date Filter: Event "${event.eventName}" removed (1 Week) because diffInDays ($diffInDays) > 7.');
            } else if ((dateFilter == '2 Weeks' && diffInDays > 14)) {
              keepEvent = false;
              debugPrint('    - Date Filter: Event "${event.eventName}" removed (2 Weeks) because diffInDays ($diffInDays) > 14.');
            } else if ((dateFilter == '1 Month' && diffInDays > 30)) {
              keepEvent = false;
              debugPrint('    - Date Filter: Event "${event.eventName}" removed (1 Month) because diffInDays ($diffInDays) > 30.');
            }
          }
        }
      } else {
        debugPrint('  Date Filter: "All" - Skipping.');
      }


      // --- Category Filter ---
      if (keepEvent && categoryFilter != 'All') { // Only apply if still kept by previous filters
        debugPrint('  Applying Category Filter ($categoryFilter)...');
        if (event.category == null || event.category!.toLowerCase() != categoryFilter.toLowerCase()) {
          keepEvent = false;
          debugPrint('    - Category Filter: Event "${event.eventName}" removed. Category: "${event.category}". Expected: "$categoryFilter".');
        }
      } else if (keepEvent) { // Only print if still kept and filter is 'All'
        debugPrint('  Category Filter: "All" - Skipping.');
      }

      // --- Time Filter ---
      if (keepEvent && timeFilter != 'All') { // Only apply if still kept by previous filters
        debugPrint('  Applying Time Filter ($timeFilter)...');
        if (event.eventTime == null || event.eventTime!.isEmpty) {
          keepEvent = false;
          debugPrint('    - Time Filter: Event "${event.eventName}" removed because eventTime is null or empty.');
        } else {
          try {
            final parsedTime = DateFormat('HH:mm').parse(event.eventTime!);
            final hour = parsedTime.hour;
            debugPrint('    - Time Filter: Event time parsed to hour: $hour.');
            if ((timeFilter == 'Morning' && (hour < 6 || hour >= 12))) {
              keepEvent = false;
              debugPrint('    - Time Filter: Event "${event.eventName}" removed (Morning) because hour ($hour) not in 6-11.');
            } else if ((timeFilter == 'Afternoon' && (hour < 12 || hour >= 18))) {
              keepEvent = false;
              debugPrint('    - Time Filter: Event "${event.eventName}" removed (Afternoon) because hour ($hour) not in 12-17.');
            } else if ((timeFilter == 'Evening' && (hour < 18 || hour >= 24))) {
              keepEvent = false;
              debugPrint('    - Time Filter: Event "${event.eventName}" removed (Evening) because hour ($hour) not in 18-23.');
            }
          } catch (e) {
            debugPrint('    - Time Filter: Error parsing event time for "${event.eventName}" in background: ${event.eventTime} - $e');
            keepEvent = false; // Filter out if time parsing fails
          }
        }
      } else if (keepEvent) { // Only print if still kept and filter is 'All'
        debugPrint('  Time Filter: "All" - Skipping.');
      }

      debugPrint('  Final decision for "${event.eventName}": ${keepEvent ? 'KEEP' : 'REMOVE'}');
      return keepEvent;
    }).toList();

    debugPrint('--- Filtering Finished ---');
    debugPrint('Filtered events count: ${filteredList.length}');
    return filteredList;
  }

  // --- New method to handle list item tap and move map ---
  void _onListEventTap(EventModel event) {
    if (event.locationLat != null && event.locationLng != null) {
      final targetLatLng = LatLng(event.locationLat!, event.locationLng!);
      _mapController.move(targetLatLng, _mapController.zoom); // Move map to event location

      // Also trigger the highlight and potential scroll if the panel isn't open
      _triggerHighlightAndScroll(event);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not available for ${event.eventName}')),
      );
    }
  }

  // New method to handle marker tap, scroll to list item, and highlight
  void _onMarkerTap(EventModel event) {
    _triggerHighlightAndScroll(event);
  }

  // Helper method to consolidate highlight and scroll logic
  void _triggerHighlightAndScroll(EventModel event) {
    if (mounted) {
      // Cancel any ongoing highlight timer to prevent conflicts
      _highlightTimer?.cancel();

      setState(() {
        _highlightedEventId = event.id; // Set the ID of the event to highlight
      });

      // Ensure the panel is open enough to see the event
      if (_panelHeightFraction < 0.3) { // Adjust this threshold as needed
        setState(() {
          _panelHeightFraction = 0.5; // Open to halfway
        });
      }

      // Give Flutter a moment to build the widget with the new key and state
      Future.delayed(const Duration(milliseconds: 100), () {
        final key = _eventItemKeys[event.id];
        if (key != null && key.currentContext != null) {
          Scrollable.ensureVisible(
            key.currentContext!,
            alignment: 0.5, // Center the item in the viewport
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          debugPrint('Key for event ${event.eventName} (ID: ${event.id}) not found or context is null.');
        }
      });

      // Start a timer to clear the highlight after a specific duration (e.g., 1 second)
      _highlightTimer = Timer(const Duration(seconds: 1), () { // Highlight for 1 second
        if (mounted) {
          setState(() {
            _highlightedEventId = null; // Clear the highlighted ID
          });
        }
      });
    }
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
                                width: 50,
                                height: 60,
                                child: EventMarker(
                                  imagePath: event.eventImageUrl ?? 'resources/img/placeholder.png',
                                  isNetworkImage: event.eventImageUrl != null,
                                  onTap: () => _onMarkerTap(event),
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
                                // Ensure the key is created for each event using event.id
                                if (_eventItemKeys[event.id] == null) {
                                  _eventItemKeys[event.id] = GlobalKey();
                                }
                                final bool isHighlighted = event.id == _highlightedEventId;

                                return Card(
                                  key: _eventItemKeys[event.id], // Assign the key here
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  elevation: 2,
                                  // Apply highlight styling for a subtle effect
                                  color: isHighlighted ? Colors.grey[200] : null, // Soft white/grey highlight
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: isHighlighted
                                        ? const BorderSide(color: Colors.blue, width: 2) // Blue border for highlight
                                        : BorderSide.none,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      debugPrint('Tapped on event: ${event.eventName}. Time: ${DateTime.now()}');
                                      _onListEventTap(event);
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
                                              child: event.eventImageUrl != null
                                                  ? Image.network(
                                                      event.eventImageUrl!,
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Image.asset(
                                                          'resources/img/placeholder.png', // Fallback image
                                                          width: 50,
                                                          height: 50,
                                                          fit: BoxFit.cover,
                                                        );
                                                      },
                                                    )
                                                  : Image.asset(
                                                      'resources/img/placeholder.png', // Default image if no URL
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
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
  final String imagePath; // This can now be a network URL or an asset path
  final bool isNetworkImage; // New parameter to differentiate image source
  final VoidCallback onTap;

  const EventMarker({
    super.key,
    required this.imagePath,
    this.isNetworkImage = false, // Default to false (asset image)
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: CustomPaint(
              // FIX: Explicitly use ui.Path in _TrianglePainter
              painter: _TrianglePainter(
                color: Colors.red[700]!, // Consistent with marker body color
              ),
              child: const SizedBox(
                width: 20, // Width of the triangle base
                height: 10, // Height of the triangle
              ),
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.red[700], // Marker body color
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: isNetworkImage
                  ? Image.network(
                      imagePath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'resources/img/placeholder.png', // Fallback asset
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      imagePath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'resources/img/placeholder.png', // Fallback asset if asset path is wrong
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
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

// --- Triangle Painter for the marker 'tail' ---
class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = ui.Paint() // FIX: Use ui.Paint to be explicit
      ..color = color
      ..style = PaintingStyle.fill;

    ui.Path path = ui.Path(); // FIX: Explicitly use ui.Path()

    // These coordinates are relative to the 'size' of the CustomPaint widget,
    // which is used to draw the triangle shape.
    path.moveTo(size.width / 2, size.height); // Bottom center
    path.lineTo(0, 0); // Top-left corner
    path.lineTo(size.width, 0); // Top-right corner
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Only repaint if the color changes (or other properties if added)
    return oldDelegate is _TrianglePainter && oldDelegate.color != color;
  }
}