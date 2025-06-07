import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/services/auth_gate.dart';
import 'package:campuslink/screens/create_event_page.dart';


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

      final _ = await _supabase.from('event').insert(insertPayload);
      //print('Response: $response');
      return true;
    } catch (e) {
      print('Error creating event: $e');
      return false;
    }
  }
}