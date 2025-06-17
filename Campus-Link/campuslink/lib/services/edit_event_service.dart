import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/models/event.dart';
import 'package:campuslink/services/event_service.dart';
import 'dart:developer';

class EditEventService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch event details by ID for editing
  static Future<EventModel?> getEventById(int eventId) async {
    try {
      final response = await _supabase
          .from('event')
          .select()
          .eq('event_id', eventId)
          .single();

      return EventModel.fromMap(response);
    } catch (e) {
      log('Error fetching event for editing: $e');
      return null;
    }
  }
  /// Update event with new details
  static Future<bool> updateEvent(EventModel eventData) async {
    try {
      log('Starting event update for event ID: ${eventData.eventId}');
      
      // Build update map based on the database schema from the images
      final Map<String, dynamic> updateData = {
        'eventname': eventData.eventName,
        'eventdescription': eventData.description,
        'eventcategory': eventData.category,
        'is_online': eventData.isOnline,
        'startdate': eventData.eventDate?.toIso8601String().split('T')[0], // Date only
        'eventTime': eventData.eventTime,
        'duration': eventData.eventDuration,
        'locationName': eventData.locationName,
        'locationLatLng': eventData.locationLat != null && eventData.locationLng != null 
            ? '${eventData.locationLat},${eventData.locationLng}' 
            : null,
        'maxnumberofpeople': eventData.maxnumberofpeople,
        'isPublic': eventData.isPublic,
        'eventimageurl': eventData.eventImageUrl,
      };

      // Remove null values to avoid overwriting existing data
      updateData.removeWhere((key, value) => value == null);
      
      log('Update data prepared: $updateData');

      final response = await _supabase
          .from('event')
          .update(updateData)
          .eq('event_id', eventData.eventId)
          .select(); // Add select to get response

      log('Database update response: $response');
      log('Event updated successfully in database');
      return true;
    } catch (e) {
      log('Error updating event: $e');
      log('Full error details: ${e.toString()}');
      return false;
    }
  }

  /// Upload new event image and optionally delete old one
  static Future<String?> uploadEventImage(File imageFile, {String? oldImageUrl}) async {
    try {
      // Upload new image using existing service
      final newImageUrl = await EventService.uploadEventImage(imageFile);
      
      if (newImageUrl != null && oldImageUrl != null && oldImageUrl.isNotEmpty) {
        // Try to delete old image (optional, don't fail if it doesn't work)
        try {
          final oldFileName = _extractFileNameFromUrl(oldImageUrl);
          if (oldFileName.isNotEmpty) {
            await _supabase.storage
                .from('eventimage')
                .remove([oldFileName]);
            log('Old image deleted: $oldFileName');
          }
        } catch (e) {
          log('Warning: Could not delete old image: $e');
          // Don't fail the operation if old image deletion fails
        }
      }

      return newImageUrl;
    } catch (e) {
      log('Error uploading event image: $e');
      return null;
    }
  }

  /// Extract filename from Supabase storage URL
  static String _extractFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.length >= 3) {
        // URL format: .../storage/v1/object/public/eventimage/filename
        return segments.last;
      }
      return '';
    } catch (e) {
      log('Error extracting filename from URL: $e');
      return '';
    }
  }

  /// Delete event (with confirmation)
  static Future<bool> deleteEvent(int eventId) async {
    try {
      // First, get event details to delete associated image
      final event = await getEventById(eventId);
      
      // Delete event image if exists
      if (event?.eventImageUrl != null && event!.eventImageUrl!.isNotEmpty) {
        try {
          final fileName = _extractFileNameFromUrl(event.eventImageUrl!);
          if (fileName.isNotEmpty) {
            await _supabase.storage
                .from('eventimage')
                .remove([fileName]);
          }
        } catch (e) {
          log('Warning: Could not delete event image during deletion: $e');
        }
      }

      // Use existing delete method
      await EventService.deleteEvent(eventId);
      
      log('Event deleted successfully');
      return true;
    } catch (e) {
      log('Error deleting event: $e');
      return false;
    }
  }
}
