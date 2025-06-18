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

  @override
  void initState() {
    super.initState();
    _locationController.text = widget.eventData.locationName ?? '';
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
          _buildDateTimePicker(),
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

  Widget _buildDateTimePicker() {
    return Card(
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
                _mapController.move(LatLng(lat, lon), 15.0);
              });
              _checkValidity();
            }
          },
        ),
        const SizedBox(height: 12),
        if (widget.eventData.location != null)
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