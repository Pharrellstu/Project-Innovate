import 'package:campuslink/screens/home_page.dart';
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

class _EventInvitationsPageState extends State<EventInvitationsPage>
    with SingleTickerProviderStateMixin {
  final EventInvitationService _invitationService = EventInvitationService();
  final UserService _userService = UserService();
  final EventService _eventService = EventService();

  List<EventInvitationModel> _enrolledInvitations = [];
  List<EventInvitationModel> _cancelledInvitations = [];
  List<EventInvitationModel> _pendingInvitations = [];
  bool _isLoading = true;
  String _errorMessage = '';

  late TabController _tabController;
  final Map<int, EventModel> _eventCache = {};
  final Map<int, UserObject> _userCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final currentUserId = AuthGate.getCurrentUserId();
      if (currentUserId == null) throw Exception('User not authenticated');

      final currentAccountId = await _userService.getAccountIdByAuthUserId(currentUserId);
      if (currentAccountId == null) throw Exception('Account not found');

      // Use fetchInvitationsForUser which now returns ALL invitations
      final allInvitations = await _invitationService.fetchInvitationsForUser(currentAccountId);

      setState(() {
        _pendingInvitations = allInvitations.where((inv) => inv.status == 'pending').toList();
        _enrolledInvitations = allInvitations.where((inv) => inv.status == 'accepted').toList();
        _cancelledInvitations = allInvitations.where((inv) => inv.status == 'declined').toList();
      });

      await _preloadEventAndUserDetails();
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load invitations: $e');
      print('Error loading invitations: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _preloadEventAndUserDetails() async {
    final allInvitations = [..._pendingInvitations, ..._enrolledInvitations, ..._cancelledInvitations];

    for (final invitation in allInvitations) {
      if (!_eventCache.containsKey(invitation.eventId)) {
        try {
          final event = await EventService.getEventById(invitation.eventId);
          if (event != null) _eventCache[invitation.eventId] = event;
        } catch (e) { print('Error loading event: $e'); }
      }

      if (!_userCache.containsKey(invitation.eventInvitationCreaterId)) {
        try {
          final user = await _userService.getUserByAccountId(invitation.eventInvitationCreaterId);
          if (user != null) _userCache[invitation.eventInvitationCreaterId] = user;
        } catch (e) { print('Error loading user: $e'); }
      }
    }
  }

  Future<void> _respondToInvitation(EventInvitationModel invitation, bool accept) async {
    try {
      await _invitationService.updateInvitationStatus(
        invitation.eventInvitationId,
        accept ? 'accepted' : 'declined',
      );

      setState(() {
        if (accept) {
          _pendingInvitations.remove(invitation);
          _enrolledInvitations.add(invitation.copyWith(status: 'accepted'));
        } else {
          _pendingInvitations.remove(invitation);
          _cancelledInvitations.add(invitation.copyWith(status: 'declined'));
        }
      });

      // show a quick success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invitation ${accept ? 'accepted' : 'declined'}!'),
          backgroundColor: accept ? Colors.green : Colors.orange,
        ),
      );

      // Re-fetch updated invitations
      await _loadInvitations(); // Reload from DB to ensure fresh data

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
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Event Invitations'),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 1,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Enrolled'),
                Tab(text: 'Cancelled'),
                Tab(text: 'Pending'),
              ],
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
            ),
          ),
          body: _buildTabContent(),
        ),
    );
  }

  Widget _buildTabContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)));
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildInvitationList(_enrolledInvitations, 'enrolled'),
        _buildInvitationList(_cancelledInvitations, 'cancelled'),
        _buildInvitationList(_pendingInvitations, 'pending'),
      ],
    );
  }

  Widget _buildInvitationList(List<EventInvitationModel> invitations, String status) {
    if (invitations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'pending' ? Icons.pending_actions :
              status == 'enrolled' ? Icons.event_available : Icons.cancel,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${status.capitalize()} invitations',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInvitations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: invitations.length,
        itemBuilder: (context, index) {
          final invitation = invitations[index];
          final event = _eventCache[invitation.eventId];
          final creator = _userCache[invitation.eventInvitationCreaterId];

          return _buildInvitationCard(invitation, event, creator, status);
        },
      ),
    );
  }

  Widget _buildInvitationCard(EventInvitationModel invitation, EventModel? event, UserObject? creator, String status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (creator != null) ...[
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        status == 'pending'
                            ? 'Invited you to an event'
                            : 'You ${status == 'enrolled' ? 'enrolled' : 'cancelled'} this event',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
              const SizedBox(height: 16),
              ],

              if (event != null) ...[
              Text(event.eventName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),

              if (event.eventDate != null)
              _buildDetailRow(Icons.calendar_today, DateFormat.yMMMd().format(event.eventDate!)),

              if (event.eventTime != null)
              _buildDetailRow(Icons.access_time, '${event.eventTime!.split(':').take(2).join(':')}'),

              if (event.locationName != null && event.locationName!.isNotEmpty)
              _buildDetailRow(Icons.location_on, event.locationName!),

              const SizedBox(height: 8),
              if (event.description.isNotEmpty)
              Text(event.description, maxLines: 3, overflow: TextOverflow.ellipsis),
              ] else
              const Text('Loading event details...', style: TextStyle(fontStyle: FontStyle.italic)),

              const SizedBox(height: 16),

              // Show buttons only for pending invitations
              if (status == 'pending')
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
                        child: const Text('Decline', style: TextStyle(color: Colors.red)),
                      ),
                    ),

                    const SizedBox(width: 16),
                    Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12)
                    ),
                    onPressed: () => _respondToInvitation(invitation, true),
                    child: const Text(
                        'Accept', style: TextStyle(
                        color: Colors.white)
                    ),
                  ),
                ),
                ],
              )
              else
              // Status indicator for non-pending
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: status == 'enrolled' ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                    color: status == 'enrolled' ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// Helper extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension StringCasingExtension on String {
  String toCapitalized() => length > 0
      ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}'
      : '';
}