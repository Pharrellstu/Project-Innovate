import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/services/auth_gate.dart';
import 'package:campuslink/screens/create_event_page.dart';
import 'package:campuslink/services/event.dart';

class EventService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<bool> createEvent(EventData data) async {
    final creatorId = AuthGate.getCurrentUserId();
    if (creatorId == null) throw Exception('No user is logged in');

    try {
      final payload = data.toMap(creatorId);

      final eventResponse = await _supabase
          .from('event')
          .insert(payload)
          .select('event_id')
          .single();

      final int newEventId = eventResponse['event_id'];

      await _supabase
          .from('chat')
          .insert({'event_id': newEventId})
          .select('chat_id')
          .single();

      return true;
    } catch (e) {
      print('Error creating event or chat: $e');
      return false;
    }
  }

  static Future<List<EventModel>> fetchEvents() async {
      final rows = await _supabase.from('event').select();
       return (rows as List<dynamic>)
           .map((r) => EventModel.fromMap(r as Map<String, dynamic>))
           .toList();
  }
}
