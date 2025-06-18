import 'dart:io';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/user.dart';
import 'create_event_screens/basic_info_screen.dart';
import 'create_event_screens/time_and_location_screen.dart';
import 'create_event_screens/privacy_and_security_screen.dart';
import 'create_event_screens/overview.dart';
import 'package:campuslink/services/event_service.dart';
import 'package:campuslink/models/eventinvitation.dart';
import 'package:campuslink/services/event_invitation_service.dart';
import 'package:campuslink/services/user_service.dart';
import 'package:campuslink/services/auth_gate.dart';

class CreateEventPage extends StatelessWidget {
  const CreateEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a New Event"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: const CreateEventForm(),
    );
  }
}

class CreateEventForm extends StatefulWidget {
  const CreateEventForm({super.key});

  @override
  State<CreateEventForm> createState() => _CreateEventFormState();
}

class _CreateEventFormState extends State<CreateEventForm> {
  int currentStep = 0;
  bool isBasicInfoValid = false;
  bool isLocationValid = false;
  bool isPrivacyValid = true; // Default to true
  final EventData _eventData = EventData();

  final EventInvitationService _invitationService = EventInvitationService();

  List<StepDefinition> get stepsMeta => [
    StepDefinition(
        title: 'Basic Info',
        content: basicInputInfo(
          eventData: _eventData,
          onValidityChanged: (isValid) =>
              setState(() => isBasicInfoValid = isValid),
        ),
        isValid: isBasicInfoValid),
    StepDefinition(
        title: 'Time & Location',
        content: timeAndLocation(
          eventData: _eventData,
          onValidityChanged: (isValid) =>
              setState(() => isLocationValid = isValid),
        ),
        isValid: isLocationValid),
    StepDefinition(
        title: 'Privacy & Details',
        content: eventFormPage(
          eventData: _eventData,
          onValidityChanged: (isValid) =>
              setState(() => isPrivacyValid = isValid),
        ),
        isValid: isPrivacyValid),
    StepDefinition(
        title: 'Overview',
        content: OverviewPage(eventData: _eventData),
        isValid: true),
  ];

  void nextStep() {
    if (currentStep < stepsMeta.length - 1) {
      setState(() => currentStep++);
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }

  Future<void> _createEventAndInvitations() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final eventId = await EventService.createEvent(_eventData);
      if (eventId == null) throw Exception('Failed to create event');

      final currentUserId = AuthGate.getCurrentUserId();
      if (currentUserId == null) throw Exception('User not authenticated');

      final currentAccountId =
      await UserService().getAccountIdByAuthUserId(currentUserId);
      if (currentAccountId == null) throw Exception('Account not found');

      if (_eventData.invitedUsers.isNotEmpty) {
        final invitations = _eventData.invitedUsers.map((user) {
          return EventInvitationModel(
            eventId: eventId,
            receiverAccountId: user.accountId!,
            eventInvitationCreaterId: currentAccountId,
          );
        }).toList();

        await _invitationService.createInvitations(invitations);
      }

      Navigator.pop(context); // Dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );
      Navigator.of(context).pop(); // Go back from create event flow
    } catch (e) {
      Navigator.pop(context); // Dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLastStep = currentStep == stepsMeta.length - 1;
    bool isStepValid = stepsMeta[currentStep].isValid;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CustomStepper(
            step: currentStep,
            stepTitles: stepsMeta.map((s) => s.title).toList(),
          ),
          const SizedBox(height: 24.0),
          Expanded(
            child: IndexedStack(
              index: currentStep,
              children: stepsMeta.map((s) => s.content).toList(),
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (currentStep > 0)
                OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: prevStep,
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                )
              else
                const SizedBox(), // To maintain space
              ElevatedButton.icon(
                icon: Icon(
                    isLastStep ? Icons.check_circle : Icons.arrow_forward),
                label: Text(isLastStep ? 'Create Event' : 'Next'),
                onPressed: !isStepValid
                    ? null
                    : () async {
                  if (isLastStep) {
                    await _createEventAndInvitations();
                  } else {
                    nextStep();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomStepper extends StatelessWidget {
  final int step;
  final List<String> stepTitles;

  const CustomStepper({Key? key, required this.step, required this.stepTitles})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step ${step + 1} of ${stepTitles.length}: ${stepTitles[step]}',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(stepTitles.length, (index) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                height: 6,
                decoration: BoxDecoration(
                  color: index <= step
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class StepDefinition {
  final String title;
  final Widget content;
  final bool isValid;

  StepDefinition(
      {required this.title, required this.content, required this.isValid});
}

// (Keep your existing EventData class here)
class EventData {
  String eventName = '';
  String? category;
  String description = '';
  bool isOnline = false;
  DateTime? eventDate;
  String? location;
  TimeOfDay? eventTime;
  Duration? eventDuration;
  bool repeatEvent = false;
  List<bool> repeatDays = [false, false, false, false, false, false, false];
  int repeatEveryWeeks = 1;
  String? locationName;
  bool isPublic = true;
  int? maxAttendees;
  DateTime? signUpDeadline;
  bool offerBadge = true;
  List<String> invitedUserIds = [];
  List<UserObject> invitedUsers = [];
  File? eventImageFile;
  String? eventImageUrl;
  String? get imagePath => eventImageFile?.path;
  DateTime? createdAt;

  String get invitedUsersDisplay {
    if (invitedUsers.isEmpty) return 'No invited users';

    final names = invitedUsers.map((u) => u.username).toList();

    if (names.length <= 3) {
      return names.join(', ');
    }

    return '${names.take(3).join(', ')} +${names.length - 3} more';
  }

  Map<String, dynamic> toMap(String creatorAccountId) {
    DateTime? startDateTime;
    if (eventDate != null && eventTime != null) {
      startDateTime = DateTime(
        eventDate!.year,
        eventDate!.month,
        eventDate!.day,
        eventTime!.hour,
        eventTime!.minute,
      );
    }

    return {
      'eventname': eventName,
      'eventdescription': description,
      'isPhysical': !isOnline,
      'startdate': startDateTime?.toIso8601String(),
      'locationName': locationName,
      'locationLatLng': location,
      'eventcategory': category,
      'maxnumberofpeople': maxAttendees,
      'eventcreatorid_uuid': creatorAccountId,
      'eventimageurl': eventImageUrl,
      'created_at': DateTime.now().toIso8601String(),
    };
  }
}