import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/models/eventenrollment.dart';

class EventEnrollmentService {
  static final _supabase = Supabase.instance.client;
  static const _table = 'eventenrollment';

  /// Create a new enrollment
  static Future<EventEnrollmentModel> create({
    required int accountId,
    required int eventId,
  }) async {
    final payload = {
      'accountid': accountId,
      'eventid':   eventId,
    };

    final resp = await _supabase
        .from(_table)
        .insert(payload)
        .select()
        .single();

    return EventEnrollmentModel.fromMap(resp as Map<String, dynamic>);
  }

  /// Fetch all enrollments
  static Future<List<EventEnrollmentModel>> fetchAll() async {
    final rows = await _supabase.from(_table).select();
    return (rows as List)
        .map((r) => EventEnrollmentModel.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  /// Fetch one by its PK
  static Future<EventEnrollmentModel?> fetchById(int id) async {
    final resp = await _supabase
        .from(_table)
        .select()
        .eq('eventenrollment_id', id)
        .maybeSingle();
    if (resp == null) return null;
    return EventEnrollmentModel.fromMap(resp as Map<String, dynamic>);
  }

  /// Update an existing enrollment
  static Future<bool> update(EventEnrollmentModel model) async {
    final resp = await _supabase
        .from(_table)
        .update(model.toMap())
        .eq('eventenrollment_id', model.eventEnrollmentId);
    return resp.error == null;
  }

  /// Delete an enrollment
  static Future<bool> delete(int id) async {
    final resp = await _supabase
        .from(_table)
        .delete()
        .eq('eventenrollment_id', id);
    return resp.error == null;
  }
}
