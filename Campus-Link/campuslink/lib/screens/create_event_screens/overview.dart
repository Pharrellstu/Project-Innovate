import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../create_event_page.dart';

class OverviewPage extends StatelessWidget {
  final EventData eventData;

  const OverviewPage({Key? key, required this.eventData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eventData.eventImageFile != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.file(
                eventData.eventImageFile!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            eventData.eventName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildInfoChip(
              eventData.category ?? 'No Category', Icons.category_outlined),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Date & Time',
            [
              _buildDetailRow('Date', _formatDate(eventData.eventDate),
                  Icons.calendar_today_rounded),
              _buildDetailRow(
                  'Time', _formatTime(eventData.eventTime, context),
                  Icons.access_time_rounded),
              // Add duration row here
              _buildDetailRow(
                  'Duration',
                  _formatDuration(eventData.eventDuration),
                  Icons.timer_rounded),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Location & Details',
            [
              _buildDetailRow(
                  'Type',
                  eventData.isOnline ? 'Online Event' : 'In-Person Event',
                  eventData.isOnline
                      ? Icons.link_rounded
                      : Icons.location_on_rounded),
              if (!eventData.isOnline)
                _buildDetailRow(
                    'Venue',
                    eventData.locationName ?? 'Not specified',
                    Icons.pin_drop_rounded),
              _buildDetailRow(
                  'Privacy',
                  eventData.isPublic ? 'Public' : 'Private',
                  eventData.isPublic
                      ? Icons.public_rounded
                      : Icons.lock_rounded),
              _buildDetailRow(
                  'Max Attendees',
                  eventData.maxAttendees?.toString() ?? 'No limit',
                  Icons.group_rounded),
            ],
          ),
          const SizedBox(height: 16),
          if (eventData.invitedUsers.isNotEmpty)
            _buildSectionCard(
              'Invited Guests (${eventData.invitedUsers.length})',
              [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: eventData.invitedUsers.map((user) {
                      return Chip(
                        avatar: CircleAvatar(
                          child: Text(user.username![0].toUpperCase()),
                        ),
                        label: Text(user.username!),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'Not specified';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '$hours hours ${minutes}m';
    } else if (hours > 0) {
      return '$hours hours';
    } else if (minutes > 0) {
      return '$minutes minutes';
    } else {
      return 'Not specified';
    }
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Chip(
      label: Text(label),
      avatar: Icon(icon, size: 16),
      backgroundColor: Colors.blue.shade50,
      labelStyle: TextStyle(
          color: Colors.blue.shade800, fontWeight: FontWeight.bold),
    );
  }

  String _formatDate(DateTime? date) =>
      date != null ? DateFormat.yMMMMd().format(date) : 'Not specified';

  String _formatTime(TimeOfDay? time, BuildContext context) =>
      time?.format(context) ?? 'Not specified';
}