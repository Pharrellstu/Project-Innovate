import 'package:flutter/material.dart';

class timeAndLocation extends StatefulWidget {
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
}