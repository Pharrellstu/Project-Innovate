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

    // Add search functionality to fetchEvents
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
    int perPage = 10,
    String? searchTerm,
  }) async {
    final from = (page - 1) * perPage;
    final to = from + perPage - 1;

    try {
      // Create base query
      var query = _supabase
          .from('event')
          .select();

      if (searchTerm != null && searchTerm.isNotEmpty) {
        if (searchTerm.length == 1) {

          query = query.ilike('eventname', '${searchTerm[0]}%');
        } else {

          query = query.ilike('eventname', '$searchTerm%');
        }
      }

      final response = await query
          .order('startdate', ascending: true)
          .range(from, to);

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
      await _supabase.rpc('delete_event', params: {'target_event_id': eventId});
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

  static Future<DateTime?> getEventCreationTime(int eventId) async {
    try {
      final response = await _supabase
          .from('event')
          .select('created_at')
          .eq('event_id', eventId)
          .single();

      if (response['created_at'] != null) {
        return DateTime.parse(response['created_at'] as String);
      }
      return null;
    } catch (e) {
      print('Error fetching creation time: $e');
      return null;
    }
  }  // Add updateEvent method to EventService for consistency
  static Future<bool> updateEvent(EventModel event) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        print('No authenticated user.');
        return false;
      }
      // Prepare update data with correct DB field names
      final updateData = <String, dynamic>{
        'eventname': event.eventName,
        'eventcategory': event.category,
        'eventdescription': event.description,
        'isPhysical': !event.isOnline,
        'startdate': event.eventDate?.toIso8601String().split('T')[0],
        'eventTime': event.eventTime,
        'duration': event.eventDuration,
        'locationName': event.locationName,
        'locationLatLng': (event.locationLat != null && event.locationLng != null) ? "${event.locationLat},${event.locationLng}" : null,
        'isPublic': event.isPublic,
        'maxnumberofpeople': event.maxnumberofpeople,
        'eventimageurl': event.eventImageUrl,
      };
      updateData.removeWhere((k, v) => v == null);
      print('[EventService] updateEvent: eventId=${event.eventId}, data=$updateData');
      final response = await _supabase
          .from('event')
          .update(updateData)
          .eq('event_id', event.eventId)
          .eq('eventcreatorid_uuid', currentUserId)
          .select('event_id');
      if (response.isNotEmpty) {
        print('[EventService] Update successful.');
        return true;
      } else {
        print('[EventService] Update failed. RLS or permission issue?');
        return false;
      }
    } catch (e) {
      print('[EventService] Exception during update: $e');
      return false;
    }
  }

  static Future<bool> isEventFull(int eventId) async {
    try {
      // Fetch event to get max capacity
      final event = await getEventById(eventId);
      if (event == null || event.maxnumberofpeople == null) return false;

      // Get current enrollment count
      final countResponse = await _supabase
          .from('eventenrollment')
          .select('eventid')
          .eq('eventid', eventId);
      final enrollmentCount = (countResponse as List).length;

      return enrollmentCount >= event.maxnumberofpeople!;
    } catch (e) {
      print('Error checking event capacity: $e');
      return false;
    }
  }

}