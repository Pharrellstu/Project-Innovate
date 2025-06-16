import 'package:campuslink/screens/create_event_page.dart';
import 'package:campuslink/screens/event_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:campuslink/models/event.dart';
import 'package:campuslink/services/event_service.dart';
import 'package:campuslink/services/auth_gate.dart';
import 'package:campuslink/services/user_service.dart';

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({super.key});

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  late Future<List<EventModel>> _createdEventsFuture;
  late Future<List<EventModel>> _joinedEventsFuture;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = AuthGate.getCurrentUserId();
    _loadEvents();
  }

  void _loadEvents() {
    if (_userId != null) {
      _createdEventsFuture = _fetchCreatedEvents();
      _joinedEventsFuture = _fetchJoinedEvents();
    } else {
      _createdEventsFuture = Future.value([]);
      _joinedEventsFuture = Future.value([]);
    }
  }

  Future<List<EventModel>> _fetchCreatedEvents() async {
    return EventService.fetchEventsCreatedByUser(_userId!);
  }

  Future<List<EventModel>> _fetchJoinedEvents() async {
    final accountId = await UserService().getAccountIdByAuthUserId(_userId!);
    if (accountId == null) return [];
    return EventService.fetchEventsJoinedByUser(accountId);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit events'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEventPage(),
                  ),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My events'),
              Tab(text: 'Joined events'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildEventsList(_createdEventsFuture, isMyEvent: true),
            _buildEventsList(_joinedEventsFuture, isMyEvent: false),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(Future<List<EventModel>> future, {required bool isMyEvent}) {
    return FutureBuilder<List<EventModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return const Center(child: Text('No events found'));
        }

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return _EventListItem(
              event: event,
              isMyEvent: isMyEvent,
              onPressed: () => _navigateToEvent(context, event, isMyEvent),
            );
          },
        );
      },
    );
  }

  void _navigateToEvent(BuildContext context, EventModel event, bool isMyEvent) {
    if (isMyEvent) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventPage(eventId: event.eventId),
        ),
      );
    } else {
      //Replace EditEventPage() with actual name of file
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventPage(eventId: event.eventId),
        ),
      );
    }

  }
}

class _EventListItem extends StatelessWidget {
  final EventModel event;
  final bool isMyEvent;
  final VoidCallback onPressed;

  const _EventListItem({
    required this.event,
    required this.isMyEvent,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: InkWell(
        onTap: onPressed,
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: event.eventImageUrl != null
                  ? NetworkImage(event.eventImageUrl!)
                  : const AssetImage('assets/placeholder.png') as ImageProvider,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.lightbulb_outline, event.eventName),
                  const SizedBox(height: 4),
                  _buildInfoRow(
                    Icons.calendar_today,
                    event.eventDate != null
                        ? DateFormat('dd/MM/yyyy').format(event.eventDate!)
                        : 'No date',
                  ),
                  const SizedBox(height: 4),
                  _buildInfoRow(
                      Icons.location_on,
                      event.locationName ?? 'Location'
                  ),
                ],
              ),
            ),
            Icon(
              isMyEvent ? Icons.edit : Icons.arrow_forward,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String? text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text ?? '',
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}