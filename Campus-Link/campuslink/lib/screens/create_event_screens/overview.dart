import 'package:flutter/material.dart';
import '../create_event_page.dart';
import 'package:campuslink/models/user.dart'; // Import user model
import 'package:intl/intl.dart';

class OverviewPage extends StatelessWidget {
  final EventData eventData;

  const OverviewPage({Key? key, required this.eventData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Event Details'),
            _buildDetailRow('Event Name', eventData.eventName),
            _buildDetailRow('Category', eventData.category ?? 'Not specified'),
            _buildDetailRow('Description', eventData.description),
            _buildDetailRow('Type', eventData.isOnline ? 'Online' : 'In-person'),

            if (!eventData.isOnline) ...[
              _buildDetailRow('Location', eventData.locationName ?? 'Not specified'),
            ],

            const SizedBox(height: 24),
            _buildSectionHeader('Date & Time'),
            _buildDetailRow('Date', _formatDate(eventData.eventDate)),
            _buildDetailRow('Time', _formatTime(eventData.eventTime)),
            _buildDetailRow('Duration', _formatDuration(eventData.eventDuration)),

            if (eventData.repeatEvent) ...[
              _buildDetailRow('Repeats', 'Every ${eventData.repeatEveryWeeks} week(s)'),
              _buildDetailRow('On days', _formatRepeatDays(eventData.repeatDays)),
            ],

            const SizedBox(height: 24),
            _buildSectionHeader('Settings'),
            _buildDetailRow('Event Type', eventData.isPublic ? 'Public' : 'Private'),
            _buildDetailRow('Max Attendees', eventData.maxAttendees?.toString() ?? 'No limit'),
            _buildDetailRow('Sign-up Deadline', _formatDate(eventData.signUpDeadline)),
            _buildDetailRow('Offer Badge', eventData.offerBadge ? 'Yes' : 'No'),

            const SizedBox(height: 24),
            _buildSectionHeader('Invited Users'),
            _buildInvitedUsersSection(),
          ],
          )
        );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitedUsersSection() {
    if (eventData.invitedUsers.isEmpty) {
      return const Text('No users invited');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${eventData.invitedUsers.length} invited users:',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: eventData.invitedUsers.map((user) {
            return Chip(
              avatar: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Text(
                  user.username!.isNotEmpty
                      ? user.username![0].toUpperCase()
                      : '?',
                  style: TextStyle(color: Colors.blue[800]),
                ),
              ),
              label: Text(user.username!),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    return date != null
        ? DateFormat.yMMMMd().format(date)
        : 'Not specified';
  }

  String _formatTime(TimeOfDay? time) {
    return time != null
        ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
        : 'Not specified';
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'Not specified';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '$hours hours $minutes minutes';
    } else if (hours > 0) {
      return '$hours hours';
    } else {
      return '$minutes minutes';
    }
  }

  String _formatRepeatDays(List<bool> days) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final selectedDays = <String>[];

    for (int i = 0; i < days.length; i++) {
      if (days[i]) {
        selectedDays.add(dayNames[i]);
      }
    }

    return selectedDays.isNotEmpty
        ? selectedDays.join(', ')
        : 'No days selected';
  }

  void _submitEvent(BuildContext context) {
    // Your submission logic here
    // Access invited user IDs via:
    //   final invitedIds = eventData.invitedUsers.map((u) => u.accountId).toList();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event created successfully!')),
    );

    Navigator.pop(context);
  }
}