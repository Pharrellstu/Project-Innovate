import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../create_event_page.dart';

class timeAndLocation extends StatefulWidget {
  final EventData eventData;
  final Function(bool) onValidityChanged;

  const timeAndLocation({
    Key? key,
    required this.eventData,
    required this.onValidityChanged,
  }) : super(key: key);

  @override
  State<timeAndLocation> createState() => _timeAndLocationState();
}

class _timeAndLocationState extends State<timeAndLocation> {
  final MapController _mapController = MapController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _eventLinkController = TextEditingController();
  bool _mapVisible = false;

  @override
  void initState() {
    super.initState();
    _locationController.text = widget.eventData.locationName ?? '';
    _mapVisible = widget.eventData.location != null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkValidity();
      }
    });
  }

  void _checkValidity() {
    final isDateValid =
        widget.eventData.eventDate != null && widget.eventData.eventTime != null;
    final isLocationValid = widget.eventData.isOnline
        ? _eventLinkController.text.isNotEmpty
        : widget.eventData.location != null;
    widget.onValidityChanged(isDateValid && isLocationValid);
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.eventData.eventDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && mounted) {
      setState(() => widget.eventData.eventDate = picked);
      _checkValidity();
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: widget.eventData.eventTime ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null && mounted) {
      setState(() => widget.eventData.eventTime = picked);
      _checkValidity();
    }
  }

  // Add duration picker method
  Future<void> _pickDuration() async {
    Duration tempDuration = widget.eventData.eventDuration ?? Duration.zero;

    Duration? newDuration = await showDialog<Duration>(
      context: context,
      builder: (context) {
        return StatefulBuilder(  // Wrap in StatefulBuilder
            builder: (context, setStateDialog) {  // Local setState for dialog
              return AlertDialog(
                title: const Text("Select Duration"),
                content: Row(
                  children: [
                    Expanded(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text("Hours"),
                        DropdownButton<int>(
                          value: tempDuration.inHours,
                          items: List.generate(12, (i) => i)
                              .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setStateDialog(() => tempDuration = Duration(  // Use setStateDialog
                                  hours: value,
                                  minutes: tempDuration.inMinutes.remainder(60)));
                            }
                          },
                        ),
                      ]),
                    ),
                    Expanded(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text("Minutes"),
                        DropdownButton<int>(
                          value: tempDuration.inMinutes.remainder(60),
                          items: List.generate(12, (i) => i * 5)
                              .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setStateDialog(() => tempDuration = Duration(  // Use setStateDialog
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
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel")),
                  TextButton(
                      onPressed: () => Navigator.pop(context, tempDuration),
                      child: const Text("OK")),
                ],
              );
            }
        );
      },
    );

    if (newDuration != null) {
      setState(() {
        widget.eventData.eventDuration = newDuration;
      });
    }
  }

  // Add event description method
  String get eventDescription {
    if (widget.eventData.eventDate == null ||
        widget.eventData.eventTime == null) {
      return "Select date and time";
    }

    final start = DateTime(
      widget.eventData.eventDate!.year,
      widget.eventData.eventDate!.month,
      widget.eventData.eventDate!.day,
      widget.eventData.eventTime!.hour,
      widget.eventData.eventTime!.minute,
    );

    final end = start.add(widget.eventData.eventDuration ?? Duration.zero);
    return "This event will take place on ${_formatDate(
        widget.eventData.eventDate!)} "
        "from ${_formatTime(widget.eventData.eventTime!)} "
        "until ${_formatTime(TimeOfDay.fromDateTime(end))}";
  }

  // Add date formatting method
  String _formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  // Add time formatting method
  String _formatTime(TimeOfDay time) {
    return time.format(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'When is the event?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Updated date time picker with duration
          Card(
            elevation: 0,
            color: Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today_rounded),
                    title: const Text('Date'),
                    trailing: Text(
                      widget.eventData.eventDate != null
                          ? DateFormat.yMMMd().format(widget.eventData.eventDate!)
                          : 'Select Date',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    onTap: _pickDate,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.access_time_rounded),
                    title: const Text('Time'),
                    trailing: Text(
                      widget.eventData.eventTime?.format(context) ?? 'Select Time',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    onTap: _pickTime,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.timer_rounded),
                    title: const Text('Duration'),
                    trailing: Text(
                      widget.eventData.eventDuration != null
                          ? "${widget.eventData.eventDuration!.inHours}h ${widget.eventData.eventDuration!.inMinutes.remainder(60)}m"
                          : 'Select Duration',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    onTap: _pickDuration,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      eventDescription,
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Add repeat event section
          _buildRepeatSection(),
          const SizedBox(height: 24),

          const Text(
            'Where is the event?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (widget.eventData.isOnline)
            _buildOnlineEventLinker()
          else
            _buildLocationPicker(),
        ],
      ),
    );
  }

  // Add repeat section widget
  Widget _buildRepeatSection() {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Repeat Event? (Feature coming soon)",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Switch(
                  value: widget.eventData.repeatEvent,
                  onChanged: (val) => setState(() => widget.eventData.repeatEvent = val),
                ),
              ],
            ),
            if (widget.eventData.repeatEvent) ...[
              const SizedBox(height: 10),
              const Text(
                "Select days to repeat the event:",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(days.length, (i) {
                  final selected = widget.eventData.repeatDays[i];
                  return GestureDetector(
                    onTap: () => setState(() => widget.eventData.repeatDays[i] = !widget.eventData.repeatDays[i]),
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: selected ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(width: 1, color: Colors.grey.shade400)),
                      child: Text(days[i], style: TextStyle(color: selected ? Colors.white : Colors.black)),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Repeat every: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  Container(
                    width: 180,
                    height: 35,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF4F3F3),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(width: 1, color: Colors.grey.shade400)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButton<int>(
                          value: widget.eventData.repeatEveryWeeks,
                          items: List.generate(10, (i) => i + 1)
                              .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => widget.eventData.repeatEveryWeeks = val);
                          },
                        ),
                        const Text(" week(s)"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineEventLinker() {
    return TextField(
      controller: _eventLinkController,
      decoration: const InputDecoration(
        hintText: 'https://...',
        prefixIcon: Icon(Icons.link_rounded),
      ),
      onChanged: (value) => _checkValidity(),
    );
  }

  Widget _buildLocationPicker() {
    return Column(
      children: [
        TypeAheadField<Map<String, dynamic>>(
          controller: _locationController,
          builder: (context, controller, focusNode) => TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Search for a location',
            ),
          ),
          suggestionsCallback: (pattern) async {
            if (pattern.length < 3) return [];
            final url = Uri.parse(
              'https://nominatim.openstreetmap.org/search?q=$pattern&format=json&addressdetails=1&limit=5',
            );
            try {
              final response = await http
                  .get(url, headers: {'User-Agent': 'CampusLinkApp/1.0'});
              if (response.statusCode == 200) {
                return (json.decode(response.body) as List)
                    .cast<Map<String, dynamic>>();
              }
            } catch (e) {
              return [];
            }
            return [];
          },
          itemBuilder: (context, suggestion) => ListTile(
            title: Text(suggestion['display_name']),
          ),
          onSelected: (suggestion) {
            final lat = double.parse(suggestion['lat']);
            final lon = double.parse(suggestion['lon']);
            final displayName = suggestion['display_name'];

            if (mounted) {
              setState(() {
                widget.eventData.location = "$lat,$lon";
                widget.eventData.locationName = displayName;
                _locationController.text = displayName;
                _mapVisible = true;
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _mapController.move(LatLng(lat, lon), 15.0);
                }
              });
              _checkValidity();
            }
          },
        ),
        const SizedBox(height: 12),
        if (_mapVisible)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _parseLocation(widget.eventData.location!),
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _parseLocation(widget.eventData.location!),
                        child: const Icon(Icons.location_pin,
                            color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
      ],
    );
  }

  LatLng _parseLocation(String location) {
    final parts = location.split(',');
    return LatLng(double.parse(parts[0]), double.parse(parts[1]));
  }
}