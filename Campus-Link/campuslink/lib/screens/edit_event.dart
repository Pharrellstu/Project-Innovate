import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:campuslink/services/event_service.dart';
import 'package:campuslink/models/event.dart';
import 'dart:developer';

// Map-related imports (from time_and_location_screen.dart)
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditEventPage extends StatefulWidget {
  final int eventId;

  const EditEventPage({super.key, required this.eventId});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _maxPeopleController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Event data
  EventModel? _eventData;
  bool _isLoading = true;
  bool _isSaving = false;

  // Date and time
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Event type and visibility
  bool _isOnline = false;
  bool _isPublic = true;

  // Image handling
  File? _newEventImage;
  String? _currentEventImageUrl;

  // Map-related variables (from time_and_location_screen.dart)
  bool _isEditingLocation = true;
  LatLng? _selectedLocation;
  MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _maxPeopleController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// Load existing event data
  Future<void> _loadEventData() async {
    setState(() => _isLoading = true);
    
    try {
      final eventData = await EventService.getEventById(widget.eventId);
      
      if (eventData != null && mounted) {
        setState(() {
          _eventData = eventData;
          
          // Populate form fields
          _eventNameController.text = eventData.eventName;
          _descriptionController.text = eventData.description;
          _categoryController.text = eventData.category ?? '';
          _maxPeopleController.text = eventData.maxnumberofpeople?.toString() ?? '';
          _durationController.text = eventData.eventDuration?.toString() ?? '';
          
          // Set date and time
          _selectedDate = eventData.eventDate;
          if (eventData.eventTime != null) {
            final timeParts = eventData.eventTime!.split(':');
            if (timeParts.length >= 2) {
              _selectedTime = TimeOfDay(
                hour: int.tryParse(timeParts[0]) ?? 0,
                minute: int.tryParse(timeParts[1]) ?? 0,
              );
            }
          }
          
          // Set event type and visibility
          _isOnline = eventData.isOnline;
          _isPublic = eventData.isPublic;
          
          // Set location data
          if (!_isOnline && eventData.locationName != null) {
            _locationController.text = eventData.locationName!;
            if (eventData.locationLat != null && eventData.locationLng != null) {
              _selectedLocation = LatLng(eventData.locationLat!, eventData.locationLng!);
              _isEditingLocation = false;
            }
          }
          
          // Set image
          _currentEventImageUrl = eventData.eventImageUrl;
          
          _isLoading = false;
        });
      } else {
        // Event not found
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event not found or access denied')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading event: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  /// Pick date for the event
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Pick time for the event
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  /// Pick event image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() => _newEventImage = File(pickedFile.path));
    }
  }

  /// Search location using geocoding package (primary method)
  Future<void> _searchLocation(String query) async {
    try {
      log('🔍 Searching location with geocoding: $query');
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        setState(() {
          _selectedLocation = LatLng(loc.latitude, loc.longitude);
          _isEditingLocation = false;
        });
        log('✅ Found location: ${loc.latitude}, ${loc.longitude}');
      }
    } catch (e) {
      log('❌ Geocoding failed: $e');
      // Fallback to manual entry
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not found. Please try a different search term.')),
      );
    }
  }

  /// Save event changes
  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an event date')),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an event time')),
      );
      return;
    }
    if (!_isOnline && (_locationController.text.isEmpty || _selectedLocation == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location for physical events')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? imageUrl = _currentEventImageUrl;
      
      // Upload new image if selected
      if (_newEventImage != null) {        imageUrl = await EventService.uploadEventImage(
          _newEventImage!,
        );
        
        if (imageUrl == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload image')),
            );
          }
          setState(() => _isSaving = false);
          return;
        }
      }

      // Create updated event model
      final updatedEvent = EventModel(
        eventId: _eventData!.eventId,
        eventName: _eventNameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
        isOnline: _isOnline,
        eventDate: _selectedDate!,
        eventTime: '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
        eventDuration: _durationController.text.isEmpty ? null : int.tryParse(_durationController.text),
        locationName: _isOnline ? null : _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        locationLat: _isOnline ? null : _selectedLocation?.latitude,
        locationLng: _isOnline ? null : _selectedLocation?.longitude,
        isPublic: _isPublic,
        maxnumberofpeople: _maxPeopleController.text.isEmpty ? null : int.tryParse(_maxPeopleController.text),
        signUpDeadline: _eventData!.signUpDeadline,
        eventCreatorUUID: _eventData!.eventCreatorUUID,
        eventImageUrl: imageUrl,
        createdAt: _eventData!.createdAt,
      );

      // Save to database
      log('Attempting to save event to database...');
      log('Event data: ${updatedEvent.eventName}, Date: ${updatedEvent.eventDate}, Location: ${updatedEvent.locationName}');
      
      final success = await EventService.updateEvent(updatedEvent);
      
      log('Database update result: $success');
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event updated successfully!')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update event')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _saveEvent,
              child: _isSaving 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save', style: TextStyle(color: Colors.blue, fontSize: 16)),
            ),
        ],
      ),      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildEventForm(),
    );
  }

  Widget _buildEventForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image Section
            _buildImageSection(),
            const SizedBox(height: 24),
            
            // Event Name
            _buildTextFormField(
              controller: _eventNameController,
              label: 'Event Name',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter event name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Description
            _buildTextFormField(
              controller: _descriptionController,
              label: 'Description (Optional)',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Category
            _buildTextFormField(
              controller: _categoryController,
              label: 'Category (Optional)',
            ),
            const SizedBox(height: 16),
            
            // Date and Time Section
            _buildDateTimeSection(),
            const SizedBox(height: 16),
            
            // Duration
            _buildTextFormField(
              controller: _durationController,
              label: 'Duration (minutes)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Max People
            _buildTextFormField(
              controller: _maxPeopleController,
              label: 'Max Participants (Optional)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Event Type Toggle
            _buildEventTypeSection(),
            const SizedBox(height: 16),
            
            // Location Section
            if (!_isOnline) ...[
              _buildLocationSection(),
              const SizedBox(height: 16),
            ],
            
            // Visibility Toggle
            _buildVisibilitySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Event Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: _newEventImage != null
                  ? Image.file(_newEventImage!, fit: BoxFit.cover)
                  : _currentEventImageUrl != null
                      ? Image.network(_currentEventImageUrl!, fit: BoxFit.cover)
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey.shade500),
                              const SizedBox(height: 8),
                              const Text('Add an event image'),
                            ],
                          ),
                        ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date & Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[50],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null
                            ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                            : 'Select Date',
                        style: TextStyle(
                          color: _selectedDate != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: _selectTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[50],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime != null
                            ? _selectedTime!.format(context)
                            : 'Select Time',
                        style: TextStyle(
                          color: _selectedTime != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEventTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Event Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Physical Event'),
                value: false,
                groupValue: _isOnline,
                onChanged: (value) => setState(() => _isOnline = value!),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Online Event'),
                value: true,
                groupValue: _isOnline,
                onChanged: (value) => setState(() => _isOnline = value!),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _locationPicker(
          selectedLocation: _selectedLocation,
          isEditingLocation: _isEditingLocation,
          mapController: _mapController,
          locationController: _locationController,
          onEdit: () => setState(() => _isEditingLocation = true),
          onLocationSelected: (latLng, displayName) {
            setState(() {
              _selectedLocation = latLng;
              _locationController.text = displayName;
              _isEditingLocation = false;
            });
            _mapController.move(latLng, 15.0);
          },
        ),
      ],
    );
  }

  Widget _buildVisibilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Event Visibility', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Public Event'),
          subtitle: Text(_isPublic ? 'Everyone can see this event' : 'Only invited users can see this event'),
          value: _isPublic,
          onChanged: (value) => setState(() => _isPublic = value),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  // Location picker widget adapted from time_and_location_screen.dart
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
                      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: 'com.example.campuslink',
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
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
              return ListTile(
                title: Text(displayName),
                leading: Icon(Icons.location_on),
              );
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

              try {
                final response = await http.get(url, headers: {
                  'User-Agent': 'CampusLinkApp/1.0 (contact@example.com)'
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
                  return []; // Return empty list on error
                }
              } catch (e) {
                return []; // Return empty list on exception
              }
            },
          ),
          SizedBox(height: 16),
          Text('Or enter location manually:', style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
        ],
      );
    }
  }
}