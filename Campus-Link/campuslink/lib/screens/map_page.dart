import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/services/event_service.dart';
import 'package:campuslink/models/event.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:campuslink/screens/create_event_page.dart';
import 'package:campuslink/screens/event_page.dart';

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

  LatLng? _currentLocation;
  final MapController _mapController = MapController();

  final Map<int, GlobalKey> _eventItemKeys = {};
  int? _highlightedEventId;
  Timer? _highlightTimer;

  String _categoryFilter = 'All';
  String _locationTypeFilter = 'All';

  @override
  void initState() {
    super.initState();
    debugPrint('[MapPage] initState called. Time: ${DateTime.now()}');

    _fetchAndFilterEvents();
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(LatLng(52.785805, 6.897585), 13.0);
    });

    _getCurrentLocation().then((loc) {
      if (mounted) {
        setState(() {
          _currentLocation = loc;
          _mapController.move(loc, _mapController.zoom);
        });
      }
    }).catchError((e) {
      if (mounted) {
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

  Future<LatLng> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return LatLng(position.latitude, position.longitude);
  }

  void _showFilterDialog() {
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
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
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

  Future<void> _fetchAndFilterEvents() async {
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
        setState(() {
          _allEvents = [];
          _filteredEventsFuture = Future.value([]);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching events: $e')),
        );
      }
    }
  }

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

  static List<EventModel> _applyFiltersStatic(Map<String, dynamic> args) {
    final List<EventModel> events = args['events'];
    final String categoryFilter = args['categoryFilter'];
    final String searchQuery = args['searchQuery'];
    final String locationTypeFilter = args['locationTypeFilter'];

    final filteredList = events.where((event) {
      bool keepEvent = true;

      // Category Filter
      if (keepEvent && categoryFilter != 'All') {
        if (event.category == null || event.category!.toLowerCase() != categoryFilter.toLowerCase()) {
          keepEvent = false;
        }
      }

      // Location Type Filter
      if (keepEvent && locationTypeFilter != 'All') {
        final isOnlineEvent = event.locationName?.toLowerCase() == 'online';
        if (locationTypeFilter == 'Online' && !isOnlineEvent) {
          keepEvent = false;
        } else if (locationTypeFilter == 'Physical' && isOnlineEvent) {
          keepEvent = false;
        }
      }

      // Search Filter
      if (keepEvent && searchQuery.isNotEmpty) {
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
        }
      }

      return keepEvent;
    }).toList();

    return filteredList;
  }

 void _onListEventTap(EventModel event) {
  if (event.locationLat != null && event.locationLng != null) {
    final targetLatLng = LatLng(event.locationLat!, event.locationLng!);
    _mapController.move(targetLatLng, _mapController.zoom);
  }
  
  // Add navigation to EventPage
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EventPage(eventId: event.eventId),
    ),
  );
  
  _triggerHighlightAndScroll(event);
}

  void _onMarkerTap(EventModel event) {
    _triggerHighlightAndScroll(event);
  }

  void _triggerHighlightAndScroll(EventModel event) {
    if (mounted) {
      _highlightTimer?.cancel();

      setState(() {
        _highlightedEventId = event.eventId;
      });

      if (_panelHeightFraction < 0.3) {
        setState(() {
          _panelHeightFraction = 0.5;
        });
      }

      Future.delayed(const Duration(milliseconds: 100), () {
        final key = _eventItemKeys[event.eventId];
        if (key != null && key.currentContext != null) {
          Scrollable.ensureVisible(
            key.currentContext!,
            alignment: 0.5,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });

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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateEventPage()),
              );
            },
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
              onTap: (tapPos, latLng) {},
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
                future: _filteredEventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  if (snapshot.hasError) {
                    return const SizedBox.shrink();
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final filteredEventsForMap = snapshot.data!;
                  return MarkerLayer(
                    markers: filteredEventsForMap
                        .map((event) {
                          final lat = event.locationLat;
                          final lng = event.locationLng;
                          if (lat == null || lng == null) {
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
          Positioned(
            top: 155,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              child: const Icon(Icons.add, color: Colors.black),
              onPressed: () {
                final currentZoom = _mapController.zoom;
                final newZoom = currentZoom + 1;
                _mapController.move(_mapController.center, newZoom);
              },
            ),
          ),
          Positioned(
            top: 210,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              child: const Icon(Icons.remove, color: Colors.black),
              onPressed: () {
                final currentZoom = _mapController.zoom;
                final newZoom = currentZoom - 1;
                _mapController.move(_mapController.center, newZoom);
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
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                },
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
                      future: _filteredEventsFuture,
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

                        final filteredEvents = snapshot.data!;
                        if (filteredEvents.isEmpty) {
                          return const Center(child: Text('No events found matching current filters.'));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = filteredEvents[index];
                            if (_eventItemKeys[event.eventId] == null) {
                              _eventItemKeys[event.eventId] = GlobalKey();
                            }
                            final bool isHighlighted = event.eventId == _highlightedEventId;

                            return Card(
                              key: _eventItemKeys[event.eventId],
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 2,
                              color: isHighlighted ? Colors.grey[200] : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: isHighlighted
                                    ? const BorderSide(color: Colors.blue, width: 2)
                                    : BorderSide.none,
                              ),
                              child: InkWell(
                                onTap: () => _onListEventTap(event),
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
                                                      'resources/img/placeholder.png',
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                )
                                              : Image.asset(
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

class EventMarker extends StatelessWidget {
  final String imagePath;
  final bool isNetworkImage;
  final VoidCallback onTap;

  const EventMarker({
    super.key,
    required this.imagePath,
    this.isNetworkImage = false,
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
              painter: _TrianglePainter(
                color: Colors.red[700]!,
              ),
              child: const SizedBox(
                width: 20,
                height: 10,
              ),
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.red[700],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
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
                          'resources/img/placeholder.png',
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
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

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