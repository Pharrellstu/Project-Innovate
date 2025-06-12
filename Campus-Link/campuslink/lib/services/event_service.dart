import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/services/auth_gate.dart';
import 'package:campuslink/screens/create_event_page.dart';
import 'package:campuslink/models/event.dart';
import 'package:campuslink/services/user_service.dart';

class EventService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<int?> createEvent(EventData data) async {
    final creatorId = AuthGate.getCurrentUserId();
    final accountId = await UserService().getAccountIdByAuthUserId(creatorId!);
    //if (creatorId == null) throw Exception('No user is logged in');
    final payload = data.toMap(creatorId);

    try {
      payload.remove('invited_user_ids');

      final eventResponse = await _supabase
          .from('event')
          .insert(payload)
          .select('event_id')
          .single();



      final int newEventId = eventResponse['event_id'];

      await _supabase
          .from('eventenrollment')
          .insert({
        'eventid':  newEventId,
        'accountid': accountId,
      });

      await _supabase
          .from('chat')
          .insert({'event_id': newEventId})
          .select('chat_id')
          .single();

      return eventResponse['event_id'] as int?;
    } catch (e) {
      print('EVENT CREATION ERROR: ${e.toString()}');
      print('PAYLOAD: $payload');
      rethrow;
    }
  }

  static Future<List<EventModel>> fetchEvents() async {
      final rows = await _supabase.from('event').select();
       return (rows as List<dynamic>)
           .map((r) => EventModel.fromMap(r as Map<String, dynamic>))
           .toList();
  }

  // Add to EventService class

  static Future<EventModel?> getEventById(int eventId) async {
    try {
      final response = await _supabase
          .from('event')
          .select()
          .eq('event_id', eventId)
          .single();

      return EventModel.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching event: $e');
      return null;
    }
  }
}
