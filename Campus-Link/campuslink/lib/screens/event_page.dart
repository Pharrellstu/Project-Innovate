import 'package:campuslink/screens/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:campuslink/services/event_service.dart';
import 'package:campuslink/models/event.dart';
import 'package:campuslink/services/eventenrollment_service.dart';
import 'package:campuslink/services/user_service.dart';
import 'package:campuslink/services/auth_gate.dart';
import 'package:intl/intl.dart';
import 'package:campuslink/screens/edit_event.dart';

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
  UserObject? _creator;
  DateTime? _creationTime;

  // Add enrollment count and full status
  int _enrollmentCount = 0;
  bool _isFull = false;

  bool get _isCreator {
    final currentUserId = AuthGate.getCurrentUserId();
    return currentUserId != null &&
        event != null &&
        event!.eventCreatorUUID == currentUserId;
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await _fetchEvent();
    await _getCurrentUserAccountId();
    await _fetchCreationTime();
    await _fetchEnrollmentCount(); // Add enrollment count fetch
  }

  // Add enrollment count fetch method
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

  // Add helper to update full status
  void _updateFullStatus() {
    if (event != null && event!.maxnumberofpeople != null) {
      setState(() {
        _isFull = _enrollmentCount >= event!.maxnumberofpeople!;
      });
    }
  }

  Future<void> _fetchEvent() async {
    try {
      final eventData = await EventService.getEventById(widget.eventId);
      if (mounted) {
        UserObject? creator;
        if (eventData != null && eventData.eventCreatorUUID != null) {
          creator =
          await UserService().getUserByAuthUserId(eventData.eventCreatorUUID!);
        }
        setState(() {
          event = eventData;
          _creator = creator;
          _isLoading = false;
        });
        _updateFullStatus(); // Update full status after event load
      }
    } catch (e) {
      print('Error fetching event: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchCreationTime() async {
    if (event == null) return;
    final time = await EventService.getEventCreationTime(widget.eventId);
    if (mounted) {
      setState(() => _creationTime = time);
    }
  }

  Future<void> _getCurrentUserAccountId() async {
    final userId = AuthGate.getCurrentUserId();
    if (userId != null) {
      final accountId = await UserService().getAccountIdByAuthUserId(userId);
      if (mounted && accountId != null) {
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
    if (mounted) {
      setState(() => _isEnrolled = isEnrolled);
    }
  }

  Future<void> _enrollInEvent() async {
    if (_currentUserAccountId == null) return;

    // Add capacity check
    if (event != null && event!.maxnumberofpeople != null) {
      final currentCount = await EventEnrollmentService.getEnrollmentCountForEvent(widget.eventId);
      if (currentCount >= event!.maxnumberofpeople!) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This event is full. Cannot join.')),
        );
        return;
      }
    }

    try {
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
      await EventEnrollmentService.unEnrollToEvent(widget.eventId,
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
    if (event != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditEventPage(eventId: event!.eventId),
        ),
      );
      // Refresh event data if edit was successful
      if (result == true && mounted) {
        await _fetchData();
      }
    }
  }

  Future<void> _deleteEvent() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event?'),
        content: const Text('This action cannot be undone.'),
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
                Navigator.pop(context); // Close event page
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : event == null
          ? const Center(child: Text('Event not found'))
          : CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCreatorInfo(),
                  if (event!.description.isNotEmpty)
                    const SizedBox(height: 24),
                  if (event!.description.isNotEmpty)
                    _buildDescriptionCard(),
                  const SizedBox(height: 24),
                  _buildMetadataCard(),
                  const SizedBox(height: 24),
                  _buildAttendanceSection(),
                  const SizedBox(height: 32),
                  _buildJoinButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          event!.eventName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: event?.eventImageUrl != null && event!.eventImageUrl!.isNotEmpty
            ? Image.network(
          event!.eventImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
        )
            : _buildImagePlaceholder(),
        stretchModes: const [StretchMode.zoomBackground],
      ),
    );
  }

  Widget _buildCreatorInfo() {
    return InkWell(
      onTap: () {
        if (_creator != null && _creator!.accountId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfilePage(
                userId: _creator!.accountId!,currentUserAccountId: _currentUserAccountId ?? 0,
              ),
            ),
          );
        }
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: _creator?.profilePictureUrl != null
                ? NetworkImage(_creator!.profilePictureUrl!) as ImageProvider
                : const AssetImage('resources/icons/profile_placeholder.png'),
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
                    fontSize: 18,
                  ),
                ),
                if (_creationTime != null)
                  Text(
                    'Posted on ${DateFormat('MMM d, yyyy').format(_creationTime!)}',
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
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'About this event',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              event!.description,
              style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMetadataItem(Icons.calendar_today, 'Date', DateFormat('MMMM dd, yyyy').format(event!.eventDate!)),
            const Divider(height: 24),
            _buildMetadataItem(Icons.location_on, 'Location', event?.locationName ?? 'Online'),
            const Divider(height: 24),
            _buildMetadataItem(Icons.category, 'Category', event?.category ?? 'Not specified'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).primaryColor),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildAttendanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Updated to show enrollment count
        Text(
          'Attendance (${_enrollmentCount}${event!.maxnumberofpeople != null ? "/${event!.maxnumberofpeople}" : ""})',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<EventEnrollmentModel>>(
          future: EventEnrollmentService.getEnrollmentsForEvent(widget.eventId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final enrollments = snapshot.data ?? [];
            if (enrollments.isEmpty) {
              return const Text('No attendees yet.');
            }
            return SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: enrollments.length,
                itemBuilder: (context, index) {
                  final accountId = enrollments[index].accountId;
                  if (accountId == null) return const SizedBox.shrink();
                  return FutureBuilder<UserObject?>(
                    future: UserService().getUserByAccountId(accountId),
                    builder: (context, userSnapshot) {
                      final user = userSnapshot.data;
                      return Padding(
                        padding: const EdgeInsets.only(right: 14.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundImage:
                              user?.profilePictureUrl != null
                                  ? NetworkImage(user!.profilePictureUrl!)
                              as ImageProvider
                                  : const AssetImage(
                                'resources/icons/profile_placeholder.png',
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 64,
                              child: Text(
                                user?.username ?? 'Loading...',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildJoinButton() {
    if (_isCreator) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit, color: Colors.white,),
              label: const Text('Edit', style: TextStyle(color: Colors.white)),
              onPressed: _editEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
              onPressed: _deleteEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      );
    }

    if (_currentUserAccountId == null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          child: const Text('Login to Join'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }

    // Updated button with full event check
    if (_isEnrolled) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _unEnrollInEvent,
          child: const Text('Leave Event', style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    } else {
      final isFull = event != null &&
          event!.maxnumberofpeople != null &&
          _enrollmentCount >= event!.maxnumberofpeople!;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isFull ? null : _enrollInEvent,
          child: Text(
              isFull ? 'Event Full' : 'Join Event',
              style: const TextStyle(fontSize: 18)
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isFull
                ? Colors.grey
                : Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(
          Icons.event,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }
}