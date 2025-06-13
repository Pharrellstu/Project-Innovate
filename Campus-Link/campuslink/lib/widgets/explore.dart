import 'package:flutter/material.dart';
import 'package:campuslink/services/event_service.dart';
import 'package:campuslink/models/event.dart';

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

  @override
  void initState() {
    super.initState();
    _loadInitialEvents();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialEvents() async {
    try {
      final initialEvents = await _fetchEvents(page: 1);
      setState(() {
        _events.addAll(initialEvents);
        _isInitialLoading = false;
        // If we got less than requested, there are no more events
        if (initialEvents.length < _perPage) {
          _hasMoreData = false;
        }
      });
    } catch (e) {
      setState(() => _isInitialLoading = false);
      // Handle error
    }
  }

  Future<List<EventModel>> _fetchEvents({int page = 1}) async {
    try {
      // Add pagination parameters to your service method
      return await EventService.fetchEvents(
        page: page,
        perPage: _perPage,
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

      if (newEvents.isEmpty) {
        setState(() => _hasMoreData = false);
      } else {
        setState(() {
          _events.addAll(newEvents);
          _currentPage++;
          // If we got less than requested, there are no more events
          if (newEvents.length < _perPage) {
            _hasMoreData = false;
          }
        });
      }
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refreshEvents() async {
    setState(() {
      _currentPage = 1;
      _hasMoreData = true;
      _isLoadingMore = false;
    });

    try {
      final refreshedEvents = await _fetchEvents(page: 1);
      setState(() {
        _events.clear();
        _events.addAll(refreshedEvents);
        // If we got less than requested, there are no more events
        if (refreshedEvents.length < _perPage) {
          _hasMoreData = false;
        }
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _refreshEvents,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: _events.isEmpty
                ? SliverFillRemaining(
              child: Center(
                child: Text(
                  'No events found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            )
                : SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) => EventCard(event: _events[index]),
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

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to event details
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: event.eventimageurl!.isNotEmpty
                  ? Image.asset(
                'resources/img/PubQuiz.png',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
              )
                  : _buildImagePlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.eventName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        // Format date properly
                        '${event.eventDate!.day}/${event.eventDate!.month}/${event.eventDate!.year}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_pin, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.locationName!,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${event.maxnumberofpeople} spots',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 150,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.event, size: 40, color: Colors.grey),
      ),
    );
  }
}