import 'package:flutter/material.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/widgets/top_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'create_event_screens/basic_info_screen.dart';
import 'create_event_screens/time_and_location_screen.dart';
import 'create_event_screens/privacy_and_security_screen.dart';

class CreateEventPage extends StatelessWidget {
  const CreateEventPage({super.key});
  final String title = "Create event";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

  int pageNumber = 1;
  //if (pageNumber => 3) pageNumber = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 25.0,
        title: IconButton(
          onPressed: () {},
          icon: Icon(Icons.arrow_back, color: Colors.black),
          splashColor: Colors.transparent, // optional: no ripple
          highlightColor: Colors.transparent, // optional: no highlight
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              child: StepIndicator(value: pageNumber),
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
                    if (pageNumber == 1) basicInputInfo(),
                    if (pageNumber == 2) timeAndLocation(),
                    if (pageNumber == 3) timeAndLocation(),

                    SizedBox(height: 40.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              pageNumber -= 1;
                              if (pageNumber <= 1) {
                                pageNumber = 1;
                              }
                            });
                          },

                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_back, color: Colors.black,),
                              SizedBox(width: 5),
                              Text(
                                'Back',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              pageNumber += 1;
                              if (pageNumber >= 3) {
                                pageNumber = 3;
                              }
                            });
                          },

                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Next',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(Icons.arrow_forward, color: Colors.black,),
                            ],
                          ),
                        ),
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

/*class basicInputInfo extends StatefulWidget {
  const basicInputInfo({super.key});

  @override
  State<basicInputInfo> createState() => _basicInputInfoState();
}

class _basicInputInfoState extends State<basicInputInfo> {

  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isOnline = false;
  String? _selectedCategory;
  int _descriptionCharCount = 0;

  // Define a list of categories with labels and icons
  final List<_Category> _categories = [
    _Category(label: 'Drinks', icon: Icons.local_bar),
    _Category(label: 'Party', icon: Icons.celebration),
    _Category(label: 'Sports', icon: Icons.sports_soccer),
    _Category(label: 'Gaming', icon: Icons.videogame_asset),
    _Category(label: 'Food', icon: Icons.fastfood),
    _Category(label: 'Other', icon: Icons.more_horiz),
  ];

  @override
  void initState() {
    super.initState();

    // Listen to description changes to update character count
    _descriptionController.addListener(() {
      setState(() {
        _descriptionCharCount = _descriptionController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isNextEnabled {
    return _eventNameController.text.trim().isNotEmpty && _selectedCategory != null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Event name",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18)
          ),
          SizedBox(height: 8),
          TextField(
            controller: _eventNameController,
            decoration: InputDecoration(
              hintText: 'e.g. Jane’s Birthday Bash', // Grey hint text
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Color(0xFBBBBBB), // Light background color
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: Colors.grey.shade700, // When focused
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: Colors.grey.shade500, // Default border
                  width: 1,
                ),
              ),
            ),
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
            onChanged: (_) {
              setState(() {
                // Trigger rebuild to update Next button state
              });
            },
          ),
          const SizedBox(height: 8),
          Text(
            'What is the category of your event? (Choose one)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
            children: _categories.map((cat) {
              final bool isSelected = _selectedCategory == cat.label;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = cat.label;
                  });
                },
                child: Semantics(
                  button: true,
                  label: 'Category: ${cat.label}',
                  selected: isSelected,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFF0066CC) : Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: Color(0xFF0066CC), width: 2)
                          : Border.all(color: Colors.transparent),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: Color(0xFF0066CC).withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          cat.icon,
                          size: 36,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 15),
          Text(
            'Event description',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Tell guests what to expect, any special notes, etc.',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Color(0xFBBBBBB),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: Colors.grey.shade700,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: Colors.grey.shade500,
                  width: 1,
                ),
              ),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_descriptionCharCount}/300',
              style: TextStyle(
                fontSize: 12,
                // color: _descriptionCharCount > 300 ? Colors.red : Colors.grey.shade700,
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Is this an online event?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Semantics(
                container: true,
                label: 'Is this an online event? Switch',
                child: Switch(
                  activeColor: Colors.white,
                  activeTrackColor: Colors.green,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade400,
                  value: _isOnline,
                  onChanged: (val) {
                    setState(() {
                      _isOnline = val;
                    });
                  },
                ),
              ),
            ],
          ),
          Text(
            _isOnline
                ? 'Guests will join via a link.'
                : 'You will add a location in the next step.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryTile(String label, String imagePath) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipOval(
          child: Image.asset(
            imagePath,
            width: 95,
            height: 95,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}*/

/*class timeAndLocation extends StatefulWidget {
  const timeAndLocation({super.key});

  @override
  State<timeAndLocation> createState() => _timeAndLocationState();
}

class _timeAndLocationState extends State<timeAndLocation> {

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 15, minute: 0);
  Duration selectedDuration = Duration.zero;

  bool repeatEvent = true;
  List<bool> repeatDays = [false, false, false, false, false, false, false];
  int repeatEveryWeeks = 1;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  Future<void> _pickDuration() async {
    Duration tempDuration = selectedDuration;
    Duration? newDuration = await showDialog<Duration>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Duration"),
        content: Row(
          children: [
            Expanded(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text("Hours"),
                DropdownButton<int>(
                  value: tempDuration.inHours,
                  items: List.generate(12, (i) => i)
                      .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => tempDuration = Duration(
                          hours: value,
                          minutes: tempDuration.inMinutes.remainder(60)));
                    }
                  },
                ),
              ]),
            ),
            Expanded(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text("Minutes"),
                DropdownButton<int>(
                  value: tempDuration.inMinutes.remainder(60),
                  items: List.generate(12, (i) => i * 5)
                      .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => tempDuration = Duration(
                          hours: tempDuration.inHours, minutes: value));
                    }
                  },
                ),
              ]),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, tempDuration),
              child: Text("OK")),
        ],
      ),
    );
    if (newDuration != null) setState(() => selectedDuration = newDuration);
  }

  String get eventDescription {
    final start = DateTime(selectedDate.year, selectedDate.month,
        selectedDate.day, selectedTime.hour, selectedTime.minute);
    final end = start.add(selectedDuration);
    return "This event will take place on ${_formatDate(selectedDate)} from ${_formatTime(selectedTime)} until ${_formatTime(TimeOfDay.fromDateTime(end))}";
  }

  String _formatDate(DateTime date) {
    const months = [
      "", "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return "${months[date.month]} ${date.day}, ${date.year}";
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period";
  }




  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          GestureDetector(
              onTap: _pickDate,
              child: _buildInputRow("Date", _formatDate(selectedDate),
                  Icons.calendar_today)),
          GestureDetector(
              onTap: _pickTime,
              child: _buildInputRow(
                  "Time", _formatTime(selectedTime), Icons.access_time)),
          GestureDetector(
              onTap: _pickDuration,
              child: _buildInputRow("Duration",
                  "${selectedDuration.inHours}h ${selectedDuration.inMinutes.remainder(60)}m", Icons.timer)),
          SizedBox(height: 8),
          Align(
              alignment: Alignment.centerLeft,
              child: Text(eventDescription,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 9,
                  ))),
          SizedBox(height: 20),
          _buildRepeatSection(),
          SizedBox(height: 20),
          //MapPage(),
        ]),
      ),
    );
  }

  Widget _buildInputRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        SizedBox(width: 10),
        Spacer(),
        Container(
          width: 180,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Color(0xFFF4F3F3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.grey),
              Text(value, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildRepeatSection() {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text("Repeat Event?", style: TextStyle(fontWeight: FontWeight.bold)),
        Switch(
          value: repeatEvent,
          onChanged: (val) => setState(() => repeatEvent = val),
        )
      ]),
      if (repeatEvent) ...[
        SizedBox(height: 10),
        Text(
          "Select days to repeat the event:",
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 15),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(days.length, (i) {
              final selected = repeatDays[i];
              return GestureDetector(
                onTap: () =>
                    setState(() => repeatDays[i] = !repeatDays[i]),
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: selected ? Colors.blue : Colors.grey[200],
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        width: 1,
                        color: Colors.grey.shade400,
                      )
                  ),
                  child: Text(days[i],
                      style: TextStyle(
                          color: selected ? Colors.white : Colors.black)),
                ),
              );
            })),
        SizedBox(height: 15),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Repeat every: ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10),
              Container(
                width: 180,
                height: 35,
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                    color: Color(0xFFF4F3F3),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      width: 1,
                      color: Colors.grey.shade400,
                    )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<int>(
                      value: repeatEveryWeeks,
                      items: List.generate(10, (i) => i + 1)
                          .map((e) => DropdownMenuItem(value: e, child: Text("[$e]")))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => repeatEveryWeeks = val);
                      },
                    ),
                    Text(" week(s)"),
                  ],
                ),
              ),
            ])
      ]
    ]);
  }
}*/


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
    if(value == 1) {
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
    } else if(value == 2) {
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
    } else if(value == 3) {
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