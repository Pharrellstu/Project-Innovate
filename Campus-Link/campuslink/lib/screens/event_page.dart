import 'package:campuslink/screens/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:campuslink/services/event_service.dart';
import 'package:campuslink/models/event.dart';
import 'package:campuslink/services/eventenrollment_service.dart';
import 'package:campuslink/services/user_service.dart';
import 'package:campuslink/services/auth_gate.dart';
import 'package:intl/intl.dart';

import '../models/eventenrollment.dart';
import '../models/user.dart';
import '../services/event_invitation_service.dart';
import 'create_event_page.dart';

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
  final ScrollController _locationController = ScrollController();
  final ScrollController _creatorController = ScrollController();
  UserObject? _creator;
  DateTime? _creationTime;

  // New state variables
  int _enrollmentCount = 0;
  bool _isFull = false;

  bool get _isCreator {
    final currentUserId = AuthGate.getCurrentUserId();
    return currentUserId != null &&
        event != null &&
        event!.eventCreatorUUID == currentUserId;
  }

  Future<void> _fetchCreationTime() async {
    final time = await EventService.getEventCreationTime(widget.eventId);
    setState(() => _creationTime = time);
  }

  @override
  void initState() {
    super.initState();
    _eventFuture = _fetchEvent();
    _getCurrentUserAccountId();
    _fetchCreationTime();
    _fetchEnrollmentCount();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll(_locationController);
      _startAutoScroll(_creatorController);
    });
  }

  void _startAutoScroll(ScrollController controller) {
    if (controller.hasClients) {
      if (controller.position.maxScrollExtent > 0) {
        Future.delayed(const Duration(seconds: 2), () {
          controller.animateTo(
            controller.position.maxScrollExtent,
            duration: Duration(seconds: controller.position.maxScrollExtent ~/ 20),
            curve: Curves.linear,
          ).then((_) {
            Future.delayed(const Duration(seconds: 1), () {
              controller.animateTo(
                0,
                duration: Duration(seconds: controller.position.maxScrollExtent ~/ 20),
                curve: Curves.linear,
              ).then((_) => _startAutoScroll(controller));
            });
          });
        });
      }
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _creatorController.dispose();
    super.dispose();
  }

  Future<EventModel?> _fetchEvent() async {
    try {
      final eventData = await EventService.getEventById(widget.eventId);
      if (eventData != null) {
        UserObject? creator;
        if (eventData.eventCreatorUUID != null) {
          creator = await UserService().getUserByAuthUserId(eventData.eventCreatorUUID!);
        }

        setState(() {
          event = eventData;
          _creator = creator;
          _isLoading = false;
        });

        // Update full status after loading event
        _updateFullStatus();
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

  // New method to fetch enrollment count
  Future<void> _fetchEnrollmentCount() async {
    try {
      final count = await EventEnrollmentService.getEnrollmentCountForEvent(widget.eventId);
      setState(() {
        _enrollmentCount = count;
        _updateFullStatus();
      });
    } catch (e) {
      print('Error fetching enrollment count: $e');
    }
  }

  // Helper to update full status
  void _updateFullStatus() {
    if (event != null && event!.maxnumberofpeople != null) {
      setState(() {
        _isFull = _enrollmentCount >= event!.maxnumberofpeople!;
      });
    }
  }

  Future<void> _enrollInEvent() async {
    if (_currentUserAccountId == null) return;

    try {
      // Check if event is full with latest count
      final currentCount = await EventEnrollmentService.getEnrollmentCountForEvent(widget.eventId);
      if (event != null &&
          event!.maxnumberofpeople != null &&
          currentCount >= event!.maxnumberofpeople!) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This event is full. Cannot join.')),
        );
        return;
      }

      await EventEnrollmentService.enrollToEvent(
        widget.eventId,
        _currentUserAccountId!,
      );

      try {
        await EventInvitationService.acceptInvitationByEventAndReceiver(
          widget.eventId,
          _currentUserAccountId!,
        );
      } catch (e) {
        print("No invitation found to update: $e");
      }

      setState(() => _isEnrolled = true);
      // Refresh enrollment count after joining
      await _fetchEnrollmentCount();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully joined the event!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to join: ${e.toString()}')),
      );
    }
  }

  Future<void> _unEnrollInEvent() async {
    if (_currentUserAccountId == null) return;

    try {
      await EventEnrollmentService.unEnrollToEvent(
        widget.eventId,
        _currentUserAccountId!,
      );
      setState(() => _isEnrolled = false);
      // Refresh enrollment count after leaving
      await _fetchEnrollmentCount();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully left the event')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to leave: ${e.toString()}')),
      );
    }
  }

  Future<void> _editEvent() async {
    // Navigate to edit screen with event data
    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventPage(),
      ),
    );*/
  }

  Future<void> _deleteEvent() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event?'),
        content: const Text('This action cannot be undone'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await EventService.deleteEvent(event!.eventId);
                Navigator.pop(context); // Close event page after deletion
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deletion failed: ${e.toString()}')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinButton() {
    // Calculate if event is full
    final isFull = event != null &&
        event!.maxnumberofpeople != null &&
        _enrollmentCount >= event!.maxnumberofpeople!;

    // Creator sees edit/delete buttons
    if (_isCreator) {
      return Row(
        children: [
          // Edit Button
          Expanded(
            child: ElevatedButton(
              onPressed: () => _editEvent(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Edit Event',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Delete Button
          Expanded(
            child: ElevatedButton(
              onPressed: () => _deleteEvent(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Delete Event',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      );
    }

    // Non-creator sees regular join button
    if (_currentUserAccountId == null) {
      return ElevatedButton(
        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
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

    if(_isEnrolled) {
      return ElevatedButton(
        onPressed: _unEnrollInEvent,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD30E26),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Leave Event',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: isFull ? null : _enrollInEvent, // Disable if full
        style: ElevatedButton.styleFrom(
          backgroundColor: isFull ? Colors.grey : Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          isFull ? 'Event Full' : 'Join Event',
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      );
    }
  }

  Widget _buildAutoScrollingText(String text, ScrollController controller) {
    return SingleChildScrollView(
      controller: controller,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
          if (controller.hasClients && controller.position.maxScrollExtent > 0)
            Text(
              "  •••  $text",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
        ],
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
          InkWell(
            onTap: () {
              if (_creator != null && _creator!.accountId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfilePage(
                      userId: _creator!.accountId!,
                      currentUserAccountId: _currentUserAccountId ?? 0,
                    ),
                  ),
                );
              }
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: _creator?.profilePictureUrl != null
                      ? NetworkImage(_creator!.profilePictureUrl!) as ImageProvider
                      : AssetImage('resources/icons/profile_placeholder.png'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _creator?.username ?? 'Unknown Creator',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        event != null && event!.eventDate != null
                            ? 'Created: ${DateFormat('MMM dd, yyyy, HH:mm').format(_creationTime!)}'
                            : 'Event date: Not specified',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Stack(
            children: [
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
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, MMM d, yyy').format(event!.eventDate!).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event!.eventName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _buildAutoScrollingText(
                            event!.locationName ?? 'Online Event',
                            _locationController,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

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
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetadataItem(Icons.category, event?.category ?? 'No Category'),
              _buildMetadataItem(Icons.calendar_today,
                  DateFormat('MM/dd').format(event!.eventDate!)),
              _buildMetadataItem(Icons.location_on, event?.locationName ?? 'Online'),
            ],
          ),
          const SizedBox(height: 32),

          _buildJoinButton(),
          const SizedBox(height: 32),

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
                    'Attendees (${enrollments.length}${event!.maxnumberofpeople != null ? "/${event!.maxnumberofpeople}" : ""})',
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
                        backgroundImage: AssetImage('resources/icons/profile_placeholder.png'),
                        child: Text(e.accountId.toString(), style: const TextStyle(color: Colors.white)),
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

  Widget _buildMetadataItem(IconData icon, String text) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Icon(icon, size: 28, color: Theme.of(context).primaryColor),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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