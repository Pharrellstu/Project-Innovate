import 'package:flutter/material.dart';
import '../create_event_page.dart';

class OverviewPage extends StatelessWidget {
  final EventData eventData;

  const OverviewPage({Key? key, required this.eventData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Review Your Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event Name: ${eventData.eventName}'),
            Text('Category: ${eventData.category}'),
            Text('Description: ${eventData.description}'),
            Text('Is Online: ${eventData.isOnline ? "Yes" : "No"}'),
            Text('Location: ${eventData.location}'),
            Text('Event Date: ${eventData.eventDate}'),
            Text('Event Time: ${eventData.eventTime}'),
            Text('Event Duration: ${eventData.eventDuration}'),
            Text('Repeat Event: ${eventData.repeatEvent ? "Yes" : "No"}'),
            Text('Repeat Days: ${eventData.repeatDays.toString()}'),
            Text('Repeat Every Weeks: ${eventData.repeatEveryWeeks}'),
            // Add other fields as necessary
          ],
        ),
      ),
    );
  }
}
