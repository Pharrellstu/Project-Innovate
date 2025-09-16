import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/models/eventenrollment.dart';

class EventEnrollmentService {
  static final _supabase = Supabase.instance.client;
  static const _table = 'eventenrollment';

  static Future<void> enrollToEvent(int eventId, int accountId) async {
    try {
      await _supabase.from(_table).insert({
        'eventid': eventId,
        'accountid': accountId,
        'enrollmentdate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error enrolling to event: $e');
      rethrow;
    }
  }

  static Future<bool> isUserEnrolled(int eventId, int accountId) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('eventid', eventId)
          .eq('accountid', accountId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking enrollment: $e');
      return false;
    }
  }

  /// Get all enrollments for an event
  static Future<List<EventEnrollmentModel>> getEnrollmentsForEvent(int eventId) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('eventid', eventId);

      return (response as List)
          .map((r) => EventEnrollmentModel.fromMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching enrollments: $e');
      return [];
    }
  }

  /// unroll user from an event
  static Future<void> unEnrollToEvent(int eventId, int accountId) async {
    try {
      await _supabase.from(_table)
        .delete()
        .eq('eventid', eventId)
        .eq('accountid', accountId);

    } catch (e) {
      print('Error enrolling to event: $e');
      rethrow;
    }
  }

  static Future<int> getEnrollmentCountForEvent(int eventId) async {
    try {
      final response = await _supabase
          .rpc('get_enrollment_count', params: {'event_id': eventId});

      return response as int? ?? 0;
    } catch (e) {
      print('Error getting enrollment count: $e');
      return 0;
    }
  }
}