import 'package:campuslink/services/event.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/services/auth_gate.dart';
import 'package:campuslink/screens/create_event_page.dart';
import 'package:campuslink/services/event.dart';


class EventService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<bool> createEvent(EventData data) async {

    final creatorId = AuthGate.getCurrentUserId();
    if (creatorId == null) {
      throw Exception('No user is logged in');
    }

    String formatTimeOfDayForDb(TimeOfDay tod) {
      final twoDigit = (int value) => value.toString().padLeft(2, '0');
      final hour   = twoDigit(tod.hour);
      final minute = twoDigit(tod.minute);
      return '$hour:$minute:00';
    }


    String? eventDateString;
    if (data.eventDate != null) {
      // Convert DateTime → "YYYY-MM-DD"
      eventDateString = data.eventDate!
          .toIso8601String()
          .split('T')
          .first;
    }

    String? eventTimeString;
    if (data.eventTime != null) {
      eventTimeString = formatTimeOfDayForDb(data.eventTime!);
    }

    try {
      //await _supabase.from('events').insert(data);
      final insertPayload = <String, dynamic>{
        'eventname': data.eventName,
        'locationLatLng': data.location,
        'maxnumberofpeople': 40,
        'eventcreatorid_uuid': creatorId,
        'startdate': eventDateString,
        'eventTime': eventTimeString,
        //'duration': data.eventDuration,
        'locationName': data.locationName,
        'isPhysical': data.isOnline,
        'eventimageurl': 'first',
        'eventcategory': data.category,
        'eventdescription': data.description,
      };

      final _ = await _supabase
          .from('event')
          .insert(insertPayload);
      //print('Response: $response');
      return true;
    } catch (e) {
      print('Error creating event: $e');
      return false;
    }
  }

  static Future<List<EventModel>> fetchEvents() async {
    try {
      final response = await _supabase
          .from('event')
          .select('*');

      // Ensure response is List<dynamic>
      if (response is! List) {
        throw Exception('Invalid response format');
      }

      return response.map<EventModel>((json) {
        // Convert to proper format for EventModel
        return EventModel.fromMap({
          'id': json['id']?.toString() ?? '',
          'event_name': json['eventname'] ?? 'Untitled Event',
          'category': json['eventcategory'],
          'description': json['eventdescription'] ?? '',
          'is_online': json['isPhysical'] ?? false,
          'event_date': json['startdate'],
          'event_time': json['eventTime'],
          'event_duration': json['duration'],
          'location_name': json['locationName'],
          'location_lat': _parseLocation(json['locationLatLng'], true),
          'location_lng': _parseLocation(json['locationLatLng'], false),
          'is_public': true, // Default to public
          'max_attendees': json['maxnumberofpeople'],
          'sign_up_deadline': null, // Not in current schema
          'offer_badge': false, // Not in current schema
          'creator_user_id': json['eventcreatorid_uuid'] ?? 'unknown',
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }

  static double? _parseLocation(dynamic location, bool isLat) {
    if (location is! String) return null;
    final parts = location.split(',');
    if (parts.length != 2) return null;

    try {
      return double.parse(isLat ? parts[0] : parts[1]);
    } catch (_) {
      return null;
    }
  }
}