import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';


class timeAndLocation extends StatefulWidget {
  const timeAndLocation({super.key});

  @override
  State<timeAndLocation> createState() => _timeAndLocationState();
}

class _timeAndLocationState extends State<timeAndLocation> {
  bool isEditingLocation = true;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 15, minute: 0);
  Duration selectedDuration = Duration.zero;

  bool repeatEvent = true;
  List<bool> repeatDays = [false, false, false, false, false, false, false];
  int repeatEveryWeeks = 1;

  LatLng? selectedLocation; // For marker// For marker
  MapController mapController = MapController();
  TextEditingController locationController = TextEditingController();
  

  Future<void> _searchLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        setState(() {
          selectedLocation = LatLng(loc.latitude, loc.longitude);
        });
      }
    } catch (e) {
      print('Location not found: $e');
    }
  }


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
          _locationPicker(
            selectedLocation: selectedLocation,
            isEditingLocation: isEditingLocation,
            mapController: mapController,
            locationController: locationController,
            onEdit: () => setState(() => isEditingLocation = true),
            onLocationSelected: (latLng, displayName) {
              setState(() {
                selectedLocation = latLng;
                locationController.text = displayName;
                isEditingLocation = false;
              });
              mapController.move(latLng, 15.0);
            },
          )
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

  Widget _locationPicker({
    required LatLng? selectedLocation,
    required bool isEditingLocation,
    required MapController mapController,
    required TextEditingController locationController,
    required void Function() onEdit,
    required void Function(LatLng latLng, String displayName) onLocationSelected,
  }) {
    if (selectedLocation != null && !isEditingLocation) {
      return Column(
        children: [
          Center(
            child: Container(
              width: 300,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center: selectedLocation,
                    zoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: selectedLocation,
                          child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: onEdit,
            icon: Icon(Icons.edit_location),
            label: Text("Edit Location"),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Search for a location:", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          TypeAheadField(
              itemBuilder: (context, suggestion) {
                final displayName = suggestion.split('|')[0];
                return ListTile(title: Text(displayName));
              },
              onSelected: (suggestion) {
                final parts = suggestion.split('|');
                final displayName = parts[0];
                final lat = double.parse(parts[1]);
                final lon = double.parse(parts[2]);

                onLocationSelected(LatLng(lat, lon), displayName);
                },
              suggestionsCallback: (pattern) async {
                if (pattern.length < 3) return [];

                final url = Uri.parse(
                  'https://nominatim.openstreetmap.org/search?q=$pattern&format=json&addressdetails=1&limit=5',
                );

                final response = await http.get(url, headers: {
                  'User-Agent': 'CampusLinkApp/1.0 (youremail@domain.com)'
                });

                if (response.statusCode == 200) {
                  final List<dynamic> data = json.decode(response.body);
                  return data.map<String>((item) {
                    final displayName = item['display_name'];
                    final lat = item['lat'];
                    final lon = item['lon'];
                    return '$displayName|$lat|$lon';
                  }).toList();
                } else {
                  return [];
                }
              },
          ),
        ],
      );
    }
  }
}