import 'package:flutter/material.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/widgets/top_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'create_event_screens/basic_info_screen.dart';
import 'create_event_screens/time_and_location_screen.dart';
import 'create_event_screens/privacy_and_security_screen.dart';
import 'create_event_screens/overview.dart';

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

  /*void updateBasicInfoValidity(bool isValid) {
    setState(() {
      isBasicInfoValid = isValid;
    });
  }

  void updateLocationValidity(bool isValid) {
    setState(() {
      isLocationValid = isValid;
    });
  }

  void updatePrivacyValidity(bool isValid) {
    setState(() {
      isPrivacyValid = isValid;
    });
  }


  List<Widget> get steps => [
    basicInputInfo(onValidityChanged: updateBasicInfoValidity, eventData: _eventData),
    timeAndLocation(onValidityChanged: updateLocationValidity, eventData: _eventData),
    eventFormPage(onValidityChanged: updatePrivacyValidity, eventData: _eventData,),
    OverviewPage(eventData: _eventData),
  ];*/

  List<Widget> get steps => [
    basicInputInfo(
      eventData: _eventData,
      onValidityChanged: (isValid) => setState(() => isBasicInfoValid = isValid),
    ),
    timeAndLocation(
      eventData: _eventData,
      onValidityChanged: (isValid) => setState(() => isLocationValid = isValid),
    ),
    eventFormPage(
      eventData: _eventData,
      onValidityChanged: (isValid) => setState(() => isPrivacyValid = isValid),
    ),
    // Add your OverviewPage here
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.all(16.0),
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
                        // In CreateEventPage's build method:
                        TextButton(
                          onPressed: () {
                            bool currentStepValid;
                            switch (currentStep) {
                              case 0:
                                currentStepValid = isBasicInfoValid;
                                break;
                              case 1:
                                currentStepValid = isLocationValid;
                                break;
                              case 2:
                                currentStepValid = true; // Event form page is always valid
                                break;
                              case 3:
                                currentStepValid = true; // Overview page is always valid
                              default:
                                currentStepValid = true;
                            }
                            return currentStepValid ? nextStep : null;
                          }(),
                          child: Text(currentStep == steps.length - 1 ? 'Finish' : 'Next'),
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
    if(value == 0) {
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
    } else if(value == 1) {
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
    } else if(value == 2) {
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

  // Add other fields from other steps as needed
  DateTime? eventDate;
  String? location;
  TimeOfDay? eventTime;
  Duration? eventDuration;
  bool repeatEvent = false;
  List<bool> repeatDays = [false, false, false, false, false, false, false];
  int repeatEveryWeeks = 1;
  LatLng? locationLatLng;
  String? locationName;
// You can also add badges, limits, privacy, etc.

  bool isPublic = true;
  int? maxAttendees;
  DateTime? signUpDeadline;
  bool offerBadge = true;
  List<String> invitedUserIds = [];
}