import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:campuslink/widgets/nav_bar.dart'; // Assuming this is your custom nav bar
import 'package:campuslink/services/event_service.dart';
import 'package:campuslink/models/event.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:campuslink/screens/create_event_page.dart';
import 'package:campuslink/screens/event_page.dart';
import 'package:collection/collection.dart'; // NEW: For grouping events by location

// NEW: Helper class to hold data from multiple futures for the main FutureBuilder.
class _PageData {
  final LatLng? userLocation;
  final List<EventModel> allEvents;
  _PageData({required this.userLocation, required this.allEvents});
}

/// A page displaying events on an interactive map with filtering and clustering.
class MapPage extends StatefulWidget {
  const MapPage({super.key});
  final String title = "Map Page";

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  // REFACTORED: Centralized future for page initialization to prevent race conditions.
  late Future<_PageData> _pageDataFuture;

  // Panel control variables
  double _panelHeightFraction = 0.25;
  late double _dragStartY;
  late double _startHeightFraction;

  // Event data management
  List<EventModel> _allEvents = [];
  Future<List<EventModel>>? _filteredEventsFuture;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Location and map controls
  final MapController _mapController = MapController();
  LatLng? _currentLocation;

  // Event highlighting system
  final Map<int, GlobalKey> _eventItemKeys = {};
  int? _highlightedEventId;
  Timer? _highlightTimer;

  // Filter states
  String _categoryFilter = 'All';
  String _locationTypeFilter = 'All';

  // Default map center (Emmen, Netherlands)
  final LatLng _defaultCenter = const LatLng(52.785805, 6.897585);

  @override
  void initState() {
    super.initState();
    // FIX: Initialize all async data in one place.
    _pageDataFuture = _initPageData();
    _searchController.addListener(_onSearchChanged);
  }

  // NEW: Fetches all initial data concurrently. This is the fix for the crash.
  Future<_PageData> _initPageData() async {
    try {
      // Run location fetching and event fetching at the same time.
      final results = await Future.wait([
        _getCurrentLocation(suppressErrors: true), // suppressErrors to not fail the whole page
        EventService.fetchEvents(),
      ]);

      final loc = results[0] as LatLng?;
      final events = results[1] as List<EventModel>;

      // Set initial state from the loaded data
      if (mounted) {
        setState(() {
          _currentLocation = loc;
          _allEvents = events;
          _applyAndSetFilteredEvents();
        });
      }

      return _PageData(userLocation: loc, allEvents: events);
    } catch (e) {
      // If fetching fails, show an error and return empty data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing page: $e')),
        );
        setState(() {
          _allEvents = [];
          _applyAndSetFilteredEvents();
        });
      }
      return _PageData(userLocation: null, allEvents: []);
    }
  }

  /// Handles changes to the search query
  void _onSearchChanged() {
    if (_searchQuery == _searchController.text) return;
    if (mounted) {
      setState(() {
        _searchQuery = _searchController.text;
        _applyAndSetFilteredEvents();
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _highlightTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  /// Retrieves the device's current location with proper permission checks
  Future<LatLng?> _getCurrentLocation({bool suppressErrors = false}) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      if (!suppressErrors && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get current location: $e')),
        );
      }
      return null;
    }
  }

  /// Shows a dialog for filtering events by category and location type
  void _showFilterDialog() {
    // ... (This function remains largely the same, no changes needed)
    String tempCategoryFilter = _categoryFilter;
    String tempLocationTypeFilter = _locationTypeFilter;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Filter Events"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Filter by Category:"),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: tempCategoryFilter,
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          tempCategoryFilter = newValue!;
                        });
                      },
                      items: <String>[
                        'All', 'Drinks', 'Party', 'Sports', 'Gaming', 'Food', 'Other'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text("Filter by Location Type:"),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: tempLocationTypeFilter,
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          tempLocationTypeFilter = newValue!;
                        });
                      },
                      items: <String>['All', 'Online', 'Physical']
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
                    setDialogState(() {
                      tempCategoryFilter = 'All';
                      tempLocationTypeFilter = 'All';
                    });
                  },
                ),
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text("Apply"),
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        _categoryFilter = tempCategoryFilter;
                        _locationTypeFilter = tempLocationTypeFilter;
                        _applyAndSetFilteredEvents();
                      });
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Refreshes the event list by re-fetching and applying filters.
  Future<void> _refreshEvents() async {
    try {
      final fetchedEvents = await EventService.fetchEvents();
      if (mounted) {
        setState(() {
          _allEvents = fetchedEvents;
          _applyAndSetFilteredEvents();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing events: $e')),
        );
      }
    }
  }


  /// Applies all current filters to the event list
  void _applyAndSetFilteredEvents() {
    if (mounted) {
      setState(() {
        _filteredEventsFuture = compute(_applyFiltersStatic, {
          'events': _allEvents,
          'categoryFilter': _categoryFilter,
          'searchQuery': _searchQuery,
          'locationTypeFilter': _locationTypeFilter,
        });
      });
    }
  }

  /// Static method for applying filters in an isolate. Remains unchanged.
  static List<EventModel> _applyFiltersStatic(Map<String, dynamic> args) {
    // ... (This function remains the same)
    final List<EventModel> events = args['events'];
    final String categoryFilter = args['categoryFilter'];
    final String searchQuery = args['searchQuery'];
    final String locationTypeFilter = args['locationTypeFilter'];

    return events.where((event) {
      bool keepEvent = true;
      if (categoryFilter != 'All' && event.category?.toLowerCase() != categoryFilter.toLowerCase()) {
        keepEvent = false;
      }
      if (locationTypeFilter != 'All') {
        final isOnlineEvent = event.locationName?.toLowerCase() == 'online';
        if (locationTypeFilter == 'Online' && !isOnlineEvent) keepEvent = false;
        if (locationTypeFilter == 'Physical' && isOnlineEvent) keepEvent = false;
      }
      if (searchQuery.isNotEmpty) {
        final lowerCaseQuery = searchQuery.toLowerCase();
        if (!(event.eventName.toLowerCase().contains(lowerCaseQuery) ||
            event.description.toLowerCase().contains(lowerCaseQuery) ||
            (event.category?.toLowerCase().contains(lowerCaseQuery) ?? false) ||
            (event.locationName?.toLowerCase().contains(lowerCaseQuery) ?? false))) {
          keepEvent = false;
        }
      }
      return keepEvent;
    }).toList();
  }


  /// Handles tapping on an event in the list, moves the map and navigates.
  void _onListEventTap(EventModel event) {
    _centerAndHighlightEvent(event);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventPage(eventId: event.eventId),
      ),
    );
  }

  // NEW: Handles tapping on a map marker or a cluster of markers.
  void _onMarkerTap(List<EventModel> events) {
    if (events.isEmpty) return;

    // If only one event, just highlight it.
    if (events.length == 1) {
      _centerAndHighlightEvent(events.first);
    } else {
      // If multiple events (a cluster), show a bottom sheet.
      _showClusterModal(events);
    }
  }

  /// Moves map to center on an event and highlights it in the list.
  void _centerAndHighlightEvent(EventModel event) {
    // Move map to the event's location
    if (event.locationLat != null && event.locationLng != null) {
      final targetLatLng = LatLng(event.locationLat!, event.locationLng!);
      _mapController.move(targetLatLng, _mapController.zoom > 15 ? _mapController.zoom : 15);
    }

    _highlightTimer?.cancel();
    if (mounted) {
      setState(() {
        _highlightedEventId = event.eventId;
      });
    }

    // Ensure panel is visible
    if (_panelHeightFraction < 0.3) {
      if(mounted) setState(() => _panelHeightFraction = 0.5);
    }

    // Scroll to the event in the list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _eventItemKeys[event.eventId];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    // Remove highlight after a delay
    _highlightTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _highlightedEventId = null);
      }
    });
  }

  // NEW: Shows a modal bottom sheet with a list of events in a cluster.
  void _showClusterModal(List<EventModel> events) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${events.length} events at this location",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (event.eventImageUrl != null
                            ? NetworkImage(event.eventImageUrl!)
                            : const AssetImage('resources/img/placeholder.png'))
                        as ImageProvider,
                      ),
                      title: Text(event.eventName),
                      subtitle: Text(event.category ?? 'No Category'),
                      onTap: () {
                        Navigator.pop(context); // Close the sheet
                        _centerAndHighlightEvent(event); // Highlight selected event
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: FutureBuilder<_PageData>(
        // FIX: Use the single future to build the UI, preventing crashes.
        future: _pageDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error loading map data: ${snapshot.error}'));
          }

          final initialData = snapshot.data!;
          return _buildMapUI(initialData);
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Map View',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterDialog,
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateEventPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMapUI(_PageData initialData) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _currentLocation ?? _defaultCenter,
            zoom: 13.0,
            onMapReady: () {
              // Move map to user location once map is ready
              _mapController.move(_currentLocation ?? _defaultCenter, 13.0);
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
                    width: 80,
                    height: 80,
                    child: const Icon(Icons.my_location, color: Colors.blueAccent, size: 30),
                  ),
                ],
              ),
            FutureBuilder<List<EventModel>>(
              future: _filteredEventsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();

                // NEW: Group events by their LatLng coordinates to handle clustering.
                final eventsByLocation = groupBy(
                  snapshot.data!.where((e) => e.locationLat != null && e.locationLng != null),
                      (EventModel event) => LatLng(event.locationLat!, event.locationLng!),
                );

                final markers = eventsByLocation.entries.map((entry) {
                  final latLng = entry.key;
                  final events = entry.value;
                  final bool isCluster = events.length > 1;

                  return Marker(
                    point: latLng,
                    width: isCluster ? 60 : 50,
                    height: isCluster ? 70 : 60,
                    child: EventMarker(
                      // Use first event's image or a placeholder for clusters
                      imagePath: events.first.eventImageUrl ?? 'resources/img/placeholder.png',
                      isNetworkImage: events.first.eventImageUrl != null,
                      clusterCount: isCluster ? events.length : 0,
                      onTap: () => _onMarkerTap(events),
                    ),
                  );
                }).toList();

                return MarkerLayer(markers: markers);
              },
            ),
          ],
        ),

        // UI IMPROVEMENT: Grouped map controls
        Positioned(
          top: 100,
          right: 16,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: 'recenter_btn',
                mini: true,
                backgroundColor: Colors.white,
                child: const Icon(Icons.my_location, color: Colors.blueAccent),
                onPressed: () async {
                  final loc = await _getCurrentLocation();
                  if (loc != null) {
                    setState(() => _currentLocation = loc);
                    _mapController.move(loc, _mapController.zoom);
                  }
                },
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'zoom_in_btn',
                mini: true,
                backgroundColor: Colors.white,
                child: const Icon(Icons.add, color: Colors.black87),
                onPressed: () => _mapController.move(_mapController.center, _mapController.zoom + 1),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'zoom_out_btn',
                mini: true,
                backgroundColor: Colors.white,
                child: const Icon(Icons.remove, color: Colors.black87),
                onPressed: () => _mapController.move(_mapController.center, _mapController.zoom - 1),
              ),
            ],
          ),
        ),

        // Search bar (positioned above the panel)
        Positioned(
          left: 12,
          right: 12,
          bottom: (_panelHeightFraction * screenHeight).clamp(100.0, screenHeight) + 12,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search events, categories, locations...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),

        // Draggable events panel
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: (_panelHeightFraction * screenHeight).clamp(100.0, screenHeight),
          child: _buildDraggablePanel(),
        ),
      ],
    );
  }

  Widget _buildDraggablePanel() {
    final screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onVerticalDragStart: (details) {
        _dragStartY = details.globalPosition.dy;
        _startHeightFraction = _panelHeightFraction;
      },
      onVerticalDragUpdate: (details) {
        double dragDelta = _dragStartY - details.globalPosition.dy;
        double newHeight = _startHeightFraction + dragDelta / screenHeight;
        if(mounted) setState(() => _panelHeightFraction = newHeight.clamp(0.1, 0.9));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: Column(
          children: [
            // Panel drag handle
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            // Events list
            Expanded(
              child: FutureBuilder<List<EventModel>>(
                future: _filteredEventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading events: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No events found matching your criteria.'));
                  }

                  final filteredEvents = snapshot.data!;
                  return RefreshIndicator(
                    onRefresh: _refreshEvents,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 20),
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = filteredEvents[index];
                        _eventItemKeys.putIfAbsent(event.eventId, () => GlobalKey());
                        final isHighlighted = event.eventId == _highlightedEventId;

                        // UI IMPROVEMENT: Using a styled Card and ListTile for a cleaner look.
                        return Card(
                          key: _eventItemKeys[event.eventId],
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: isHighlighted ? 6 : 2,
                          color: isHighlighted ? Colors.lightBlue[50] : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: isHighlighted
                                ? BorderSide(color: Colors.blueAccent.withOpacity(0.7), width: 2)
                                : BorderSide.none,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _onListEventTap(event),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: ClipOval(
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[200],
                                  child: event.eventImageUrl != null
                                      ? Image.network(
                                    event.eventImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.event),
                                  )
                                      : const Icon(Icons.event),
                                ),
                              ),
                              title: Text(
                                event.eventName.isNotEmpty ? event.eventName : 'Unnamed Event',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    "${event.category ?? 'No Category'} • ${event.locationName ?? 'No Location'}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    event.eventDate != null
                                        ? DateFormat('EEE, MMM d, yyyy').format(event.eventDate!)
                                        : 'No Date',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom widget for displaying event markers on the map, now with cluster support.
class EventMarker extends StatelessWidget {
  final String imagePath;
  final bool isNetworkImage;
  final VoidCallback onTap;
  final int clusterCount; // NEW: To show the number of events in a cluster.

  const EventMarker({
    super.key,
    required this.imagePath,
    this.isNetworkImage = false,
    required this.onTap,
    this.clusterCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCluster = clusterCount > 0;
    final markerColor = isCluster ? Colors.blue.shade700 : Colors.red.shade700;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Marker pointer triangle
          Positioned(
            bottom: isCluster ? 10 : 0,
            child: CustomPaint(
              painter: _TrianglePainter(color: markerColor),
              child: const SizedBox(width: 20, height: 10),
            ),
          ),
          // Circular marker with event image or cluster count
          Container(
            width: isCluster ? 60 : 50,
            height: isCluster ? 60 : 50,
            decoration: BoxDecoration(
              color: markerColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 5, offset: Offset(0, 2))],
            ),
            child: isCluster
                ? Center(
              child: Text(
                clusterCount.toString(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            )
                : ClipOval(
              child: isNetworkImage
                  ? Image.network(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Image.asset('resources/img/placeholder.png', fit: BoxFit.cover),
              )
                  : Image.asset(imagePath, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the marker's pointer triangle.
class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = ui.Paint()..color = color;
    final path = ui.Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}