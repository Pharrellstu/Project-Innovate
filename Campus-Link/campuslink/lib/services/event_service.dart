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
    try {
      //await _supabase.from('events').insert(data);
      final insertPayload = <String, dynamic>{
        'eventname': data.eventName,
        'eventdescription': data.description,
        //'eventdate': data.eventDate,
        //'eventtime': data.eventTime,
        'eventcreatorid': creatorId,
      };

      final response = await _supabase.from('event').insert(insertPayload);
      //print('Response: $response');
      return true;
    } catch (e) {
      print('Error creating event: $e');
      return false;
    }
  }
}