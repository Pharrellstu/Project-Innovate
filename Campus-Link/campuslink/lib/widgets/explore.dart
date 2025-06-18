import 'package:flutter/material.dart';
import 'package:campuslink/services/event_service.dart';
import 'package:campuslink/models/event.dart';
import 'dart:async';

import '../screens/event_page.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final EventService _eventService = EventService();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  bool _isInitialLoading = true;
  final List<EventModel> _events = [];
  final int _perPage = 10; // Number of events to load per page

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadInitialEvents();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialEvents() async {
    try {
      final initialEvents = await _fetchEvents(page: 1);
      if(mounted) {
        setState(() {
          _events.addAll(initialEvents);
          _isInitialLoading = false;
          if (initialEvents.length < _perPage) {
            _hasMoreData = false;
          }
        });
      }
    } catch (e) {
      if(mounted) {
        setState(() => _isInitialLoading = false);
      }
      // Handle error
    }
  }

  Future<List<EventModel>> _fetchEvents({int page = 1}) async {
    try {
      return await EventService.fetchEvents(
        page: page,
        perPage: _perPage,
        searchTerm: _searchController.text.trim(),
      );
    } catch (e) {
      // Handle error
      return [];
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreData) {
      _loadMoreEvents();
    }
  }

  Future<void> _loadMoreEvents() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() => _isLoadingMore = true);

    try {
      final newEvents = await _fetchEvents(page: _currentPage + 1);

      if(mounted) {
        if (newEvents.isEmpty) {
          setState(() => _hasMoreData = false);
        } else {
          setState(() {
            _events.addAll(newEvents);
            _currentPage++;
            if (newEvents.length < _perPage) {
              _hasMoreData = false;
            }
          });
        }
      }
    } finally {
      if(mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  Future<void> _refreshEvents() async {
    setState(() {
      _currentPage = 1;
      _hasMoreData = true;
      _isLoadingMore = false;
      _isInitialLoading = true;
    });

    try {
      final refreshedEvents = await _fetchEvents(page: 1);
      if(mounted) {
        setState(() {
          _events.clear();
          _events.addAll(refreshedEvents);
          if (refreshedEvents.length < _perPage) {
            _hasMoreData = false;
          }
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      if(mounted) {
        setState(() => _isInitialLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshEvents,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            expandedHeight: 0,
            toolbarHeight: 60,
            titleSpacing: 12,
            title: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _refreshEvents();
                    setState(() {});
                  },
                )
                    : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {});

                if (_debounceTimer?.isActive ?? false) {
                  _debounceTimer!.cancel();
                }

                _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    _refreshEvents();
                  }
                });
              },
            ),
          ),
          _isInitialLoading
              ? const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()))
              : _events.isEmpty
              ? SliverFillRemaining(
            child: Center(
              child: Text(
                'No events found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          )
              : SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) => EventCard(
                  event: _events[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EventPage(eventId: _events[index].eventId),
                      ),
                    );
                  },
                ),
                childCount: _events.length,
              ),
            ),
          ),
          if (_isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (!_hasMoreData && _events.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('No more events')),
              ),
            )
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            _buildImageWithGradient(),
            _buildEventInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWithGradient() {
    return Stack(
      fit: StackFit.expand,
      children: [
        event.eventImageUrl != null && event.eventImageUrl!.isNotEmpty
            ? Image.network(
          event.eventImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildImagePlaceholder(),
        )
            : _buildImagePlaceholder(),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.5, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventInfo(BuildContext context) {
    return Positioned(
      bottom: 10,
      left: 10,
      right: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            event.eventName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          _buildInfoRow(
            Icons.calendar_today,
            '${event.eventDate!.day}/${event.eventDate!.month}/${event.eventDate!.year}',
          ),
          const SizedBox(height: 4),
          _buildInfoRow(Icons.location_pin, event.locationName ?? 'No location'),
          if (event.maxnumberofpeople != null) ...[
            const SizedBox(height: 4),
            _buildInfoRow(Icons.people, '${event.maxnumberofpeople} spots'),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.white70),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.event, size: 50, color: Colors.grey),
      ),
    );
  }
}