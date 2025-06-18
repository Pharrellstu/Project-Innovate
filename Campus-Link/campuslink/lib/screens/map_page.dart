import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/services/event_service.dart';
import 'package:campuslink/models/event.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart'; // For compute
import 'dart:ui' as ui; // For ui.Path, ui.Paint

import 'dart:async'; // For Timer

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

  List<EventModel> _allEvents = [];
  Future<List<EventModel>>? _filteredEventsFuture;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  LatLng? _currentLocation; // This will hold the user's current location

  String _dateFilter = 'All';
  String _categoryFilter = 'All';
  String _timeFilter = 'All';

  final MapController _mapController = MapController(); // Initialized here

  final Map<int, GlobalKey> _eventItemKeys = {};
  int? _highlightedEventId;
  Timer? _highlightTimer;

  @override
  void initState() {
    super.initState();
    debugPrint('[MapPage] initState called. Time: ${DateTime.now()}');

    _fetchAndFilterEvents(); // Fetch events on startup
    _searchController.addListener(_onSearchChanged); // Listen to search input changes

    // Schedule the initial map move after the first frame has been rendered.
    // This ensures that the _mapController's internal state is fully initialized
    // by the FlutterMap widget.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(LatLng(52.785805, 6.897585), 13.0); // Coordinates for Emmen, Netherlands
      debugPrint('[MapPage] Initial map moved to Emmen via post-frame callback. Time: ${DateTime.now()}');
    });

    // Attempt to get the current location. This is an asynchronous operation.
    _getCurrentLocation().then((loc) {
      if (mounted) {
        setState(() {
          _currentLocation = loc; // Update _currentLocation with fetched data
          // Move map to the actual current location once obtained.
          // Maintain the initial zoom level (_mapController.zoom) or set a specific one (e.g., 13.0).
          _mapController.move(loc, _mapController.zoom); // Use current zoom, which will be 13.0 from post-frame callback or user interaction
        });
        debugPrint('[MapPage] Current location updated and map moved to $loc. Time: ${DateTime.now()}');
      }
    }).catchError((e) {
      debugPrint('[MapPage] Error getting current location during initState: $e. Time: ${DateTime.now()}');
      if (mounted) {
        // If getting location fails, show a snackbar message.
        // The map will remain at the default Emmen location set above by post-frame callback.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get current location: $e. Displaying default map area (Emmen).')),
        );
      }
    });
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {
        _searchQuery = _searchController.text;
        _applyAndSetFilteredEvents(); // Re-filter events with the new search query
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _highlightTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    debugPrint('[MapPage] dispose called. Time: ${DateTime.now()}');
    super.dispose();
  }

  // Method to get the user's current location using geolocator
  Future<LatLng> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled on the device.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check existing location permission status.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // If denied, request permission from the user.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // If permission is still denied after request, return an error.
        return Future.error('Location permissions are denied');
      }
    }

    // If permissions are permanently denied, return an error.
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // If permissions are granted, get the current position.
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high); // Request high accuracy
    return LatLng(position.latitude, position.longitude);
  }

  // Method to show the filter dialog
  void _showFilterDialog() {
    // Store current filter values temporarily for dialog state
    String tempDateFilter = _dateFilter;
    String tempCategoryFilter = _categoryFilter;
    String tempTimeFilter = _timeFilter;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // Use StatefulBuilder to update dialog content dynamically
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Filter Events"),
              content: SingleChildScrollView( // Allow content to scroll if it overflows
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Make column only take necessary space
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Filter by Date:"),
                    DropdownButton<String>(
                      isExpanded: true, // Make dropdown take full width
                      value: tempDateFilter,
                      onChanged: (String? newValue) {
                        setDialogState(() { // Update dialog's state
                          tempDateFilter = newValue!;
                        });
                      },
                      items: <String>['All', '1 Week', '2 Weeks', '1 Month'] // Date filter options
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text("Filter by Category:"),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: tempCategoryFilter,
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          tempCategoryFilter = newValue!;
                        });
                      },
                      items: <String>[ // Category filter options
                        'All',
                        'Sports',
                        'Culture',
                        'Academic',
                        'Social',
                        'Workshop',
                        'Other'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text("Filter by Time of Day:"),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: tempTimeFilter,
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          tempTimeFilter = newValue!;
                        });
                      },
                      items: <String>['All', 'Morning', 'Afternoon', 'Evening'] // Time of day filter options
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("Reset"),
                  onPressed: () {
                    setDialogState(() { // Reset filters within the dialog
                      tempDateFilter = 'All';
                      tempCategoryFilter = 'All';
                      tempTimeFilter = 'All';
                    });
                  },
                ),
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
                TextButton(
                  child: const Text("Apply"),
                  onPressed: () {
                    if (mounted) {
                      setState(() { // Apply filters to the main state
                        _dateFilter = tempDateFilter;
                        _categoryFilter = tempCategoryFilter;
                        _timeFilter = tempTimeFilter;
                        _applyAndSetFilteredEvents(); // Trigger event refiltering
                      });
                    }
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Fetches all events and then triggers initial filtering
  Future<void> _fetchAndFilterEvents() async {
    try {
      final fetchedEvents = await EventService.fetchEvents();
      if (mounted) {
        setState(() {
          _allEvents = fetchedEvents; // Store all fetched events
          _applyAndSetFilteredEvents(); // Apply current filters to them
        });
        debugPrint('[MapPage] Events fetched and initial filter applied. Total: ${_allEvents.length}. Time: ${DateTime.now()}');
      }
    } catch (e) {
      debugPrint('[MapPage] Error fetching events: $e. Time: ${DateTime.now()}');
      if (mounted) {
        setState(() {
          _allEvents = []; // Clear events on error
          _filteredEventsFuture = Future.value([]); // Ensure future resolves to empty list
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching events: $e')),
        );
      }
    }
  }

  // Applies the current filters and sets the future for filtered events
  void _applyAndSetFilteredEvents() {
    if (mounted) {
      setState(() {
        // Use compute for heavy filtering to avoid blocking UI thread
        _filteredEventsFuture = compute(_applyFiltersStatic, {
          'events': _allEvents,
          'dateFilter': _dateFilter,
          'categoryFilter': _categoryFilter,
          'timeFilter': _timeFilter,
          'searchQuery': _searchQuery,
        });
      });
      debugPrint('[MapPage] Filters re-applied. Time: ${DateTime.now()}');
    }
  }

  // Static method for filtering events (can be run in an isolate via compute)
  static List<EventModel> _applyFiltersStatic(Map<String, dynamic> args) {
    final List<EventModel> events = args['events'];
    final String dateFilter = args['dateFilter'];
    final String categoryFilter = args['categoryFilter'];
    final String timeFilter = args['timeFilter'];
    final String searchQuery = args['searchQuery'];

    final now = DateTime.now();

    debugPrint('--- Filtering Started ---');
    debugPrint('Current Date: $now');
    debugPrint('Active Filters: Date="$dateFilter", Category="$categoryFilter", Time="$timeFilter", Search="$searchQuery"');
    debugPrint('Total events received for filtering: ${events.length}');

    final filteredList = events.where((event) {
      bool keepEvent = true;
      debugPrint('\nProcessing Event: "${event.eventName}" (ID: ${event.eventId})');
      debugPrint('   Event Data: Date=${event.eventDate}, Category=${event.category}, Time=${event.eventTime}, Lat=${event.locationLat}, Lng=${event.locationLng}');

      // Date Filter
      if (dateFilter != 'All') {
        debugPrint('   Applying Date Filter ($dateFilter)...');
        if (event.eventDate == null) {
          keepEvent = false;
          debugPrint('     - Date Filter: Event "${event.eventName}" removed because eventDate is null.');
        } else {
          final diff = event.eventDate!.difference(now);
          if (diff.isNegative) { // Event is in the past
            keepEvent = false;
            debugPrint('     - Date Filter: Event "${event.eventName}" removed because it is in the past (diff: $diff).');
          } else {
            final diffInDays = diff.inDays;
            if ((dateFilter == '1 Week' && diffInDays > 7)) {
              keepEvent = false;
              debugPrint('     - Date Filter: Event "${event.eventName}" removed (1 Week) because diffInDays ($diffInDays) > 7.');
            } else if ((dateFilter == '2 Weeks' && diffInDays > 14)) {
              keepEvent = false;
              debugPrint('     - Date Filter: Event "${event.eventName}" removed (2 Weeks) because diffInDays ($diffInDays) > 14.');
            } else if ((dateFilter == '1 Month' && diffInDays > 30)) {
              keepEvent = false;
              debugPrint('     - Date Filter: Event "${event.eventName}" removed (1 Month) because diffInDays ($diffInDays) > 30.');
            }
          }
        }
      } else {
        debugPrint('   Date Filter: "All" - Skipping.');
      }

      // Category Filter
      if (keepEvent && categoryFilter != 'All') {
        debugPrint('   Applying Category Filter ($categoryFilter)...');
        if (event.category == null || event.category!.toLowerCase() != categoryFilter.toLowerCase()) {
          keepEvent = false;
          debugPrint('     - Category Filter: Event "${event.eventName}" removed. Category: "${event.category}". Expected: "$categoryFilter".');
        }
      } else if (keepEvent) {
        debugPrint('   Category Filter: "All" - Skipping.');
      }

      // Time Filter
      if (keepEvent && timeFilter != 'All') {
        debugPrint('   Applying Time Filter ($timeFilter)...');
        if (event.eventTime == null || event.eventTime!.isEmpty) {
          keepEvent = false;
          debugPrint('     - Time Filter: Event "${event.eventName}" removed because eventTime is null or empty.');
        } else {
          try {
            final parsedTime = DateFormat('HH:mm').parse(event.eventTime!);
            final hour = parsedTime.hour;
            debugPrint('     - Time Filter: Event time parsed to hour: $hour.');
            if ((timeFilter == 'Morning' && (hour < 6 || hour >= 12))) {
              keepEvent = false;
              debugPrint('     - Time Filter: Event "${event.eventName}" removed (Morning) because hour ($hour) not in 6-11.');
            } else if ((timeFilter == 'Afternoon' && (hour < 12 || hour >= 18))) {
              keepEvent = false;
              debugPrint('     - Time Filter: Event "${event.eventName}" removed (Afternoon) because hour ($hour) not in 12-17.');
            } else if ((timeFilter == 'Evening' && (hour < 18 || hour >= 24))) {
              keepEvent = false;
              debugPrint('     - Time Filter: Event "${event.eventName}" removed (Evening) because hour ($hour) not in 18-23.');
            }
          } catch (e) {
            debugPrint('     - Time Filter: Error parsing event time for "${event.eventName}" in background: ${event.eventTime} - $e');
            keepEvent = false;
          }
        }
      } else if (keepEvent) {
        debugPrint('   Time Filter: "All" - Skipping.');
      }

      // Search Filter
      if (keepEvent && searchQuery.isNotEmpty) {
        debugPrint('   Applying Search Filter ("$searchQuery")...');
        final lowerCaseQuery = searchQuery.toLowerCase();
        final String eventName = event.eventName.toLowerCase();
        final String description = event.description.toLowerCase();
        final String category = event.category?.toLowerCase() ?? '';
        final String locationName = event.locationName?.toLowerCase() ?? '';

        if (!eventName.contains(lowerCaseQuery) &&
            !description.contains(lowerCaseQuery) &&
            !category.contains(lowerCaseQuery) &&
            !locationName.contains(lowerCaseQuery)) {
          keepEvent = false;
          debugPrint('     - Search Filter: Event "${event.eventName}" removed because it does not match query "$searchQuery".');
        }
      } else if (keepEvent) {
        debugPrint('   Search Filter: Empty - Skipping.');
      }

      debugPrint('   Final decision for "${event.eventName}": ${keepEvent ? 'KEEP' : 'REMOVE'}');
      return keepEvent;
    }).toList();

    debugPrint('--- Filtering Finished ---');
    debugPrint('Filtered events count: ${filteredList.length}');
    return filteredList;
  }

  // Handles tap on an event in the list view
  void _onListEventTap(EventModel event) {
    if (event.locationLat != null && event.locationLng != null) {
      final targetLatLng = LatLng(event.locationLat!, event.locationLng!);
      // Move map to the tapped event's location
      _mapController.move(targetLatLng, _mapController.zoom);

      _triggerHighlightAndScroll(event); // Highlight and scroll to the event
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not available for ${event.eventName}')),
      );
    }
  }

  // Handles tap on a marker on the map
  void _onMarkerTap(EventModel event) {
    _triggerHighlightAndScroll(event); // Highlight and scroll to the event
  }

  // Triggers highlighting and scrolling to a specific event in the list
  void _triggerHighlightAndScroll(EventModel event) {
    if (mounted) {
      _highlightTimer?.cancel(); // Cancel any existing highlight timer

      setState(() {
        _highlightedEventId = event.eventId; // Set the event to be highlighted
      });

      // Expand the panel if it's too small to show the event clearly
      if (_panelHeightFraction < 0.3) {
        setState(() {
          _panelHeightFraction = 0.5;
        });
      }

      // After a short delay, ensure the highlighted item is visible in the list
      Future.delayed(const Duration(milliseconds: 100), () {
        final key = _eventItemKeys[event.eventId];
        if (key != null && key.currentContext != null) {
          Scrollable.ensureVisible(
            key.currentContext!,
            alignment: 0.5, // Center the item if possible
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          debugPrint('Key for event ${event.eventName} (ID: ${event.eventId}) not found or context is null.');
        }
      });

      // Remove highlight after a short duration
      _highlightTimer = Timer(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _highlightedEventId = null;
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
      extendBodyBehindAppBar: true, // Allows content to go behind the app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0, // No shadow
        title: const Text(
          'Map View',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        actions: [
          // Filter button
          IconButton(
            icon: Image.asset("resources/icons/filter.png", width: 24, height: 24),
            onPressed: _showFilterDialog,
          ),
          // New Post (Create Event) button
          IconButton(
            icon: Image.asset("resources/icons/newPostBtn.png"),
            onPressed: () => Navigator.pushNamed(context, '/create_event_page'),
          ),
        ],
      ),
      body: Stack(
        children: [
          // FlutterMap widget covering the entire body
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // Center will be set in initState or updated by location services
              center: _currentLocation ?? LatLng(52.785805, 6.897585), // Default to Emmen if _currentLocation is null
              zoom: 13.0,
              onTap: (tapPos, latLng) {
                debugPrint('Map tapped at: $latLng. Time: ${DateTime.now()}');
              },
            ),
            children: [
              // OpenStreetMap Tile Layer
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              // Current Location Marker
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
              // Event Markers (loaded from _filteredEventsFuture)
              FutureBuilder<List<EventModel>>(
                future: _filteredEventsFuture,
                builder: (context, snapshot) {
                  debugPrint('[Map Markers FutureBuilder] Connection state: ${snapshot.connectionState}. Time: ${DateTime.now()}');
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink(); // Hide markers while loading
                  }
                  if (snapshot.hasError) {
                    debugPrint('Error fetching/filtering events for map: ${snapshot.error}. Time: ${DateTime.now()}');
                    return const SizedBox.shrink(); // Hide markers on error
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    debugPrint('No events data for map or data is empty. Time: ${DateTime.now()}');
                    return const SizedBox.shrink(); // Hide markers if no data
                  }

                  final filteredEventsForMap = snapshot.data!;
                  debugPrint('Events for map after filtering: ${filteredEventsForMap.length}. Time: ${DateTime.now()}');

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
                        .whereType<Marker>() // Filter out any null markers
                        .toList(),
                  );
                },
              ),
            ],
          ),

          // My Location Button
          Positioned(
            top: 100,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.blue),
              onPressed: () async {
                debugPrint('[MapPage] My Location button pressed. Time: ${DateTime.now()}');
                try {
                  final loc = await _getCurrentLocation();
                  if (mounted) {
                    setState(() {
                      _currentLocation = loc;
                      _mapController.move(loc, _mapController.zoom);
                    });
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error getting your location: $e')),
                    );
                  }
                }
              },
            ),
          ),
          // Zoom In Button
          Positioned(
            top: 155, // Position below "My Location" button
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              child: const Icon(Icons.add, color: Colors.black),
              onPressed: () {
                final currentZoom = _mapController.zoom;
                final newZoom = currentZoom + 1; // Increase zoom level by 1
                _mapController.move(_mapController.center, newZoom);
              },
            ),
          ),
          // Zoom Out Button
          Positioned(
            top: 210, // Position below "Zoom In" button
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              child: const Icon(Icons.remove, color: Colors.black),
              onPressed: () {
                final currentZoom = _mapController.zoom;
                final newZoom = currentZoom - 1; // Decrease zoom level by 1
                _mapController.move(_mapController.center, newZoom);
              },
            ),
          ),

          // Search Bar
          Positioned(
            left: 12,
            right: 12,
            bottom: (_panelHeightFraction * screenHeight) + 12, // Position above the draggable panel
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear(); // Clear search text
                          },
                        )
                      : const Icon(Icons.search), // Search icon when empty
                  border: InputBorder.none, // No border for the TextField
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onSubmitted: (value) {
                  FocusScope.of(context).unfocus(); // Dismiss keyboard on submit
                },
              ),
            ),
          ),

          // Draggable Panel for Event List
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _panelHeightFraction * screenHeight, // Height controlled by drag
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)), // Rounded top corners
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2))], // Shadow
              ),
              child: Column(
                children: [
                  // Drag handle
                  GestureDetector(
                    behavior: HitTestBehavior.translucent, // Makes entire area draggable
                    onVerticalDragStart: (details) {
                      _dragStartY = details.globalPosition.dy;
                      _startHeightFraction = _panelHeightFraction;
                    },
                    onVerticalDragUpdate: (details) {
                      double dragDelta = _dragStartY - details.globalPosition.dy;
                      double newHeight = _startHeightFraction + dragDelta / screenHeight;
                      newHeight = newHeight.clamp(0.1, 0.9); // Clamp height between 10% and 90%
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
                  // Event List (Expanded to fill remaining space)
                  Expanded(
                    child: FutureBuilder<List<EventModel>>(
                      future: _filteredEventsFuture,
                      builder: (context, snapshot) {
                        debugPrint('[Event List FutureBuilder] Connection state: ${snapshot.connectionState}. Time: ${DateTime.now()}');
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator()); // Loading indicator
                        }
                        if (snapshot.hasError) {
                          debugPrint('Error loading events for list: ${snapshot.error}. Time: ${DateTime.now()}');
                          return Center(child: Text('Error loading events: ${snapshot.error}')); // Error message
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          debugPrint('No events data for list or data is empty. Time: ${DateTime.now()}');
                          return const Center(child: Text('No events found.')); // Message for no events
                        }

                        final filteredEvents = snapshot.data!;
                        debugPrint('Events for list after filtering: ${filteredEvents.length}. Time: ${DateTime.now()}');

                        if (filteredEvents.isEmpty) {
                          return const Center(child: Text('No events found matching current filters.')); // Message for no filtered events
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = filteredEvents[index];
                            // Create a GlobalKey for each event item for scrolling
                            if (_eventItemKeys[event.eventId] == null) {
                              _eventItemKeys[event.eventId] = GlobalKey();
                            }
                            final bool isHighlighted = event.eventId == _highlightedEventId;

                            return Card(
                              key: _eventItemKeys[event.eventId], // Assign key to Card
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 2,
                              color: isHighlighted ? Colors.grey[200] : null, // Highlight color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: isHighlighted
                                    ? const BorderSide(color: Colors.blue, width: 2) // Blue border for highlighted
                                    : BorderSide.none,
                              ),
                              child: InkWell(
                                onTap: () {
                                  debugPrint('Tapped on event: ${event.eventName}. Time: ${DateTime.now()}');
                                  _onListEventTap(event); // Handle tap
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
                                              ? Image.network( // Display network image if available
                                                  event.eventImageUrl!,
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Image.asset( // Fallback to local placeholder on error
                                                      'resources/img/placeholder.png',
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                )
                                              : Image.asset( // Display placeholder if no image URL
                                                  'resources/img/placeholder.png',
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
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Navigation Bar at the bottom
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
// This widget creates the visual marker for events on the map.
class EventMarker extends StatelessWidget {
  final String imagePath;
  final bool isNetworkImage; // Indicates if imagePath is a network URL
  final VoidCallback onTap; // Callback when the marker is tapped

  const EventMarker({
    super.key,
    required this.imagePath,
    this.isNetworkImage = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Handle taps on the marker
      child: Stack(
        alignment: Alignment.center, // Center children within the stack
        children: [
          // The triangular pointer at the bottom of the marker
          Positioned(
            bottom: 0,
            child: CustomPaint(
              painter: _TrianglePainter(
                color: Colors.red[700]!, // Color matches the marker circle
              ),
              child: const SizedBox(
                width: 20,
                height: 10,
              ),
            ),
          ),
          // The circular part of the marker with the event image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.red[700], // Background color of the circle
              shape: BoxShape.circle, // Makes it a circle
              border: Border.all(color: Colors.white, width: 2), // White border
              boxShadow: const [ // Subtle shadow for depth
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval( // Clips the image to the circular shape
              child: isNetworkImage
                  ? Image.network( // Load from network if it's a URL
                      imagePath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset( // Fallback to local placeholder on error
                          'resources/img/placeholder.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset( // Load from assets if not a network image
                      imagePath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Custom Painter for the Triangle ---
// This class draws the small triangle at the bottom of the EventMarker.
class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Corrected to explicitly use dart:ui's Path and Paint classes
    final paint = ui.Paint()..color = color; // Create a Paint object with the specified color
    final path = ui.Path() // Create a Path object for drawing
      ..moveTo(size.width / 2, size.height) // Move to the bottom-center point
      ..lineTo(0, 0) // Draw line to top-left corner
      ..lineTo(size.width, 0) // Draw line to top-right corner
      ..close(); // Close the path to form a triangle
    canvas.drawPath(path, paint); // Draw the defined path on the canvas with the paint
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false; // No need to repaint if properties don't change
}