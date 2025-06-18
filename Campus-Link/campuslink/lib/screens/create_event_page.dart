import 'dart:io';

import 'package:flutter/material.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/widgets/top_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import '../models/user.dart';
import 'create_event_screens/basic_info_screen.dart';
import 'create_event_screens/time_and_location_screen.dart';
import 'create_event_screens/privacy_and_security_screen.dart';
import 'create_event_screens/overview.dart';
import 'package:campuslink/services/event_service.dart';
import 'package:campuslink/models/eventinvitation.dart';
import 'package:campuslink/services/event_invitation_service.dart';
import 'package:campuslink/services/auth_gate.dart';

class CreateEventPage extends StatelessWidget {
  const CreateEventPage({super.key});
  final String title = "Create event";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: createEventPage(),
      bottomNavigationBar: NavBar(),
    );
  }
}

class createEventPage extends StatefulWidget {
  const createEventPage({super.key});

  @override
  State<createEventPage> createState() => _createEventPageState();
}

class _createEventPageState extends State<createEventPage> {
  int currentStep = 0;
  bool isBasicInfoValid = false;
  bool isLocationValid = false;
  bool isPrivacyValid = false;
  final EventData _eventData = EventData();

  final EventService _eventService = EventService();
  final EventInvitationService _invitationService = EventInvitationService();
  final AuthGate _authService = AuthGate();

  List<Widget> get steps => [
    basicInputInfo(
      eventData: _eventData,
      onValidityChanged: (isValid) =>
          setState(() => isBasicInfoValid = isValid),
    ),
    timeAndLocation(
      eventData: _eventData,
      onValidityChanged: (isValid) =>
          setState(() => isLocationValid = isValid),
    ),
    eventFormPage(
      eventData: _eventData,
      onValidityChanged: (isValid) =>
          setState(() => isPrivacyValid = isValid),
    ),
    OverviewPage(eventData: _eventData),
  ];

  void nextStep() {
    if (currentStep < steps.length - 1) {
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
      await userService.getAccountIdByAuthUserId(currentUserId);
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

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.all(0.0),
        child: Column(
          children: [
            Container(
              child: StepIndicator(value: currentStep),
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFFD5EAFF),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: IndexedStack(index: currentStep, children: steps)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (currentStep > 0)
                          TextButton(onPressed: prevStep, child: Text('Back')),
                        TextButton(
                          onPressed: () async {
                            final isLastStep = currentStep == steps.length - 1;
                            bool currentStepValid;

                            switch (currentStep) {
                              case 0:
                                currentStepValid = isBasicInfoValid;
                                break;
                              case 1:
                                currentStepValid = isLocationValid;
                                break;
                              case 2:
                                currentStepValid = true;
                                break;
                              case 3:
                                currentStepValid = true;
                                break;
                              default:
                                currentStepValid = true;
                            }
                            if (!currentStepValid) return;

                            if (isLastStep) {
                              await _createEventAndInvitations();
                            } else {
                              nextStep();
                            }
                          },
                          child: Text(
                              currentStep == steps.length - 1 ? 'Finish' : 'Next'
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StepIndicator extends StatelessWidget {
  final int value;
  StepIndicator({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _stepIndicator(value),
    );
  }

  Widget _stepBox(bool isActive, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: isActive ? Colors.blue : Color(0xFFD5EAFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color(0xFFD5EAFF),
            width: 2,
          )
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _stepIndicator(int value) {
    if (value == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepBox(true, '1. Basic Info'),
          Container(width: 15, height: 3, color: Color(0xFFD5EAFF)),
          _stepBox(false, '2'),
          Container(width: 15, height: 3, color: Color(0xFFD5EAFF)),
          _stepBox(false, '3'),
        ],
      );
    } else if (value == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepBox(false, '1'),
          Container(width: 15, height: 3, color: Color(0xFFD5EAFF)),
          _stepBox(true, '2. Time & Location'),
          Container(width: 15, height: 3, color: Color(0xFFD5EAFF)),
          _stepBox(false, '3'),
        ],
      );
    } else if (value == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepBox(false, '1'),
          Container(width: 15, height: 3, color: Color(0xFFD5EAFF)),
          _stepBox(false, '2'),
          Container(width: 15, height: 3, color: Color(0xFFD5EAFF)),
          _stepBox(true, '3. Privacy & Settings'),
        ],
      );
    } else if (value == 3) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepBox(true, 'Review your event'),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepBox(true, '1. Basic Info'),
        Container(width: 15, height: 3, color: Color(0xFFD5EAFF)),
        _stepBox(false, '2'),
        Container(width: 15, height: 3, color: Color(0xFFD5EAFF)),
        _stepBox(false, '3'),
      ],
    );
  }
}

class _Category {
  final String label;
  final IconData icon;

  _Category({
    required this.label,
    required this.icon,
  });
}

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