import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/services/auth_gate.dart';
import 'package:campuslink/screens/create_event_page.dart';
import 'package:campuslink/models/event.dart';
import 'package:campuslink/services/user_service.dart';

class EventService {
  static final SupabaseClient _supabase = Supabase.instance.client;

// In event_service.dart
  static Future<int?> createEvent(EventData data) async {
    final creatorId = AuthGate.getCurrentUserId();
    final accountId = await UserService().getAccountIdByAuthUserId(creatorId!);

    // Upload image if exists and not already uploaded
    if (data.eventImageFile != null && data.eventImageUrl == null) {
      final imageUrl = await uploadEventImage(data.eventImageFile!);
      if (imageUrl != null) {
        data.eventImageUrl = imageUrl;
      }
    }

    final payload = data.toMap(creatorId);

    payload['eventcreatorid_uuid'] = creatorId;

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

  static Future<List<EventModel>> fetchEvents({
    int page = 1,
    int perPage = 10
  }) async {
    final from = (page - 1) * perPage;
    final to = from + perPage - 1;

    try {
      final response = await _supabase
          .from('event')
          .select()
          .order('startdate', ascending: true)
          .range(from, to); // Add range filter here

      return (response as List<dynamic>)
          .map((r) => EventModel.fromMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

// In event_service.dart
  static Future<String?> uploadEventImage(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final bytes = await imageFile.readAsBytes();

      // Use uploadBinary instead of upload
      await _supabase.storage
          .from('eventimage')
          .uploadBinary(fileName, bytes);

      // If we get here, upload was successful
      final publicUrl = _supabase.storage
          .from('eventimage')
          .getPublicUrl(fileName);

      return publicUrl;
    } on StorageException catch (e) {
      print('Storage error: ${e.message}');
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Add to EventService class

  static Future<EventModel?> getEventById(int eventId) async {
    try {
      final response = await _supabase
          .from('event')
          .select()
          .eq('event_id', eventId)
          .single();

      return EventModel.fromMap(response);
    } catch (e) {
      print('Error fetching event: $e');
      return null;
    }
  }

  static Future<void> deleteEvent(int eventId) async {
    try {
      await _supabase
          .from('event')
          .delete()
          .eq('event_id', eventId);
    } catch (e) {
      print('Event deletion error: $e');
      rethrow;
    }
  }

  // Add these methods to the EventService class
  static Future<List<EventModel>> fetchEventsCreatedByUser(String userId) async {
    try {
      final response = await _supabase
          .from('event')
          .select()
          .eq('eventcreatorid_uuid', userId)
          .order('startdate', ascending: false);

      return (response as List<dynamic>)
          .map((r) => EventModel.fromMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching created events: $e');
      return [];
    }
  }

// Fetch events joined by a specific user (using accountId)
  static Future<List<EventModel>> fetchEventsJoinedByUser(int accountId) async {
    try {
      // First get event IDs from enrollment table
      final enrollmentResponse = await _supabase
          .from('eventenrollment')
          .select('eventid')
          .eq('accountid', accountId);

      if (enrollmentResponse.isEmpty) return [];

      final eventIds = (enrollmentResponse as List<dynamic>)
          .map<int>((e) => e['eventid'] as int)
          .toList();

      // Get current user ID
      final currentUserId = AuthGate.getCurrentUserId();

      // Fetch events excluding those created by current user
      final eventsResponse = await _supabase
          .from('event')
          .select()
          .inFilter('event_id', eventIds)
          .neq('eventcreatorid_uuid', currentUserId!) // Exclude user's own events
          .order('startdate', ascending: false);

      return (eventsResponse as List<dynamic>)
          .map((r) => EventModel.fromMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching joined events: $e');
      return [];
    }
  }
}
