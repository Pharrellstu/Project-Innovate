import 'package:flutter/material.dart';
import 'package:campuslink/services/event_service.dart';
import 'package:campuslink/models/event.dart';
import 'package:campuslink/services/eventenrollment_service.dart';
import 'package:campuslink/services/user_service.dart';
import 'package:campuslink/services/auth_gate.dart';
import 'package:intl/intl.dart';

import '../models/eventenrollment.dart';

class EventPage extends StatefulWidget {
  final int eventId;

  const EventPage({Key? key, required this.eventId}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  late Future<EventModel?> _eventFuture;
  bool _isEnrolled = false;
  bool _isLoading = true;
  EventModel? event;
  int? _currentUserAccountId;

  @override
  void initState() {
    super.initState();
    _eventFuture = _fetchEvent();
    _getCurrentUserAccountId();
  }

  Future<EventModel?> _fetchEvent() async {
    try {
      final eventData = await EventService.getEventById(widget.eventId);
      if (eventData != null) {
        setState(() {
          event = eventData;
          _isLoading = false;
        });
        return eventData;
      }
    } catch (e) {
      print('Error fetching event: $e');
    }
    setState(() => _isLoading = false);
    return null;
  }

  Future<void> _getCurrentUserAccountId() async {
    final userId = AuthGate.getCurrentUserId();
    if (userId != null) {
      final accountId = await UserService().getAccountIdByAuthUserId(userId);
      if (accountId != null) {
        setState(() => _currentUserAccountId = accountId);
        _checkEnrollmentStatus(accountId);
      }
    }
  }

  Future<void> _checkEnrollmentStatus(int accountId) async {
    final isEnrolled = await EventEnrollmentService.isUserEnrolled(
      widget.eventId,
      accountId,
    );
    setState(() => _isEnrolled = isEnrolled);
  }

  Future<void> _enrollInEvent() async {
    if (_currentUserAccountId == null) return;

    try {
      await EventEnrollmentService.enrollToEvent(
        widget.eventId,
        _currentUserAccountId!,
      );
      setState(() => _isEnrolled = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully joined the event!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to join: ${e.toString()}')),
      );
    }
  }

  Widget _buildJoinButton() {
    if (_currentUserAccountId == null) {
      return ElevatedButton(
        onPressed: () {
          // Navigate to login if not authenticated
          Navigator.pushReplacementNamed(context, '/login');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Login to Join',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      );
    }

    return ElevatedButton(
      onPressed: _isEnrolled ? null : _enrollInEvent,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isEnrolled
            ? Colors.grey
            : Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        _isEnrolled ? 'Already Joined' : 'Join Event',
        style: TextStyle(
          fontSize: 18,
          color: _isEnrolled ? Colors.black87 : Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Event not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Event Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Event header with creator info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: event?.eventImageUrl != null
                    ? NetworkImage(event!.eventImageUrl!)
                    : const AssetImage('resources/icons/profile_placeholder.png')
                as ImageProvider,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event?.creatorUserId ?? 'Unknown Creator',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created ${DateFormat('MMM dd').format(event!.eventDate!)}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Event', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Event image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: event?.eventImageUrl != null && event!.eventImageUrl!.isNotEmpty
                ? Image.network(
              event!.eventImageUrl!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildImagePlaceholder(),
            )
                : _buildImagePlaceholder(),
          ),
          const SizedBox(height: 20),

          // Event title and date
          Text(
            event!.eventName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                DateFormat('EEE, MMM d • h:mm a').format(event!.eventDate!),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Location info
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event!.locationName ?? 'Online Event',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Description
          Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event!.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 32),

          // Join button
          _buildJoinButton(),
          const SizedBox(height: 32),

          // Attendance section
          FutureBuilder<List<EventEnrollmentModel>>(
            future: EventEnrollmentService.getEnrollmentsForEvent(widget.eventId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final enrollments = snapshot.data ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendees (${enrollments.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (enrollments.isEmpty)
                    const Text('No attendees yet')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: enrollments
                          .map((e) => CircleAvatar(
                        radius: 24,
                        child: Text(e.accountId.toString()),
                      ))
                          .toList(),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.event, size: 60, color: Colors.grey),
      ),
    );
  }
}