import 'package:campuslink/screens/home_page.dart';
import 'package:campuslink/screens/post_page.dart';
import 'package:flutter/material.dart';
import 'package:campuslink/models/eventinvitation.dart';
import 'package:campuslink/services/event_invitation_service.dart';
import 'package:campuslink/services/user_service.dart';
import 'package:campuslink/services/auth_gate.dart';
import 'package:campuslink/models/event.dart';
import 'package:campuslink/services/event_service.dart';
import 'package:campuslink/models/user.dart';
import 'package:intl/intl.dart';

class EventInvitationsPage extends StatefulWidget {
  const EventInvitationsPage({super.key});

  @override
  State<EventInvitationsPage> createState() => _EventInvitationsPageState();
}

class _EventInvitationsPageState extends State<EventInvitationsPage> {
  final EventInvitationService _invitationService = EventInvitationService();
  final UserService _userService = UserService();
  final EventService _eventService = EventService();

  List<EventInvitationModel> _invitations = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Map to cache event and user details
  final Map<int, EventModel> _eventCache = {};
  final Map<int, UserObject> _userCache = {};

  @override
  void initState() {
    super.initState();
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Get current user's account ID
      final currentUserId = AuthGate.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final currentAccountId = await _userService.getAccountIdByAuthUserId(currentUserId);
      if (currentAccountId == null) {
        throw Exception('Account not found');
      }

      // Fetch invitations for the current user
      final invitations = await _invitationService.fetchInvitationsForUser(currentAccountId);

      setState(() {
        _invitations = invitations;
      });

      // Preload event and user details for better UX
      await _preloadEventAndUserDetails();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load invitations: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _preloadEventAndUserDetails() async {
    for (final invitation in _invitations) {
      // Load event details if not in cache
      if (!_eventCache.containsKey(invitation.eventId)) {
        try {
          final event = await EventService.getEventById(invitation.eventId);
          if (event != null) {
            _eventCache[invitation.eventId] = event;
          }
        } catch (e) {
          print('Error loading event ${invitation.eventId}: $e');
        }
      }

      // Load creator details if not in cache
      if (!_userCache.containsKey(invitation.eventInvitationCreaterId)) {
        try {
          final user = await _userService.getUserByAccountId(invitation.eventInvitationCreaterId);
          if (user != null) {
            _userCache[invitation.eventInvitationCreaterId] = user;
          }
        } catch (e) {
          print('Error loading user ${invitation.eventInvitationCreaterId}: $e');
        }
      }
    }
  }

  Future<void> _respondToInvitation(EventInvitationModel invitation, bool accept) async {
    try {
      // Update invitation status in database
      await _invitationService.updateInvitationStatus(
          invitation.eventInvitationId,
          accept ? 'accepted' : 'declined'
      );

      // Remove from local list
      setState(() {
        _invitations.removeWhere((i) => i.eventInvitationId == invitation.eventInvitationId);
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invitation ${accept ? 'accepted' : 'declined'}!'),
          backgroundColor: accept ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to respond: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Invitations'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()),),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_invitations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No event invitations',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'You\'ll see invitations here when someone invites you to an event',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInvitations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _invitations.length,
        itemBuilder: (context, index) {
          final invitation = _invitations[index];
          final event = _eventCache[invitation.eventId];
          final creator = _userCache[invitation.eventInvitationCreaterId];

          return _buildInvitationCard(invitation, event, creator);
        },
      ),
    );
  }

  Widget _buildInvitationCard(
      EventInvitationModel invitation,
      EventModel? event,
      UserObject? creator
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (creator != null)
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    backgroundImage: creator.profilePictureUrl != null && creator.profilePictureUrl!.isNotEmpty
                        ? NetworkImage(creator.profilePictureUrl!)
                        : null,
                    child: creator.profilePictureUrl == null || creator.profilePictureUrl!.isEmpty
                        ? const Icon(Icons.person, color: Colors.blue)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          creator.username ?? 'Unknown user',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          'Invited you to an event',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            if (event != null) ...[
              Text(
                event.eventName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 8),

              if (event.eventDate != null)
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat.yMMMd().format(event.eventDate!),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

              const SizedBox(height: 4),

              if (event.eventTime != null)
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      '${event.eventTime!.split(':').take(2).join(':')}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

              const SizedBox(height: 4),

              if (event.locationName != null && event.locationName!.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.locationName!,
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 8),

              if (event.description.isNotEmpty)
                Text(
                  event.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87),
                ),
            ] else ...[
              const Text(
                'Loading event details...',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    onPressed: () => _respondToInvitation(invitation, false),
                    child: const Text(
                      'Decline',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _respondToInvitation(invitation, true),
                    child: const Text(
                      'Accept',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}