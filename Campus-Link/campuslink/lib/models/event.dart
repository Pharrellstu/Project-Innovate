import 'package:flutter/material.dart'; // Keep if you use other Flutter specific imports here, otherwise remove
import 'package:intl/intl.dart';

class EventModel {
  final String id;
  final String eventName;
  final String? category;
  final String description;
  final bool isOnline;
  final DateTime? eventDate;
  final String? eventTime;
  final int? eventDuration;
  final String? locationName;
  final double? locationLat;
  final double? locationLng;
  final bool isPublic;
  final int? maxAttendees;
  final DateTime? signUpDeadline;
  //final bool offerBadge;
  final String creatorUserId;

  EventModel({
    required this.id,
    required this.eventName,
    this.category,
    required this.description,
    required this.isOnline,
    this.eventDate,
    this.eventTime,
    this.eventDuration,
    this.locationName,
    this.locationLat,
    this.locationLng,
    required this.isPublic,
    this.maxAttendees,
    this.signUpDeadline,
    //required this.offerBadge,
    required this.creatorUserId,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    double? _parse(String? loc, bool getLat) {
      if (loc == null) return null;
      final parts = loc.split(',');
      if (parts.length != 2) return null;
      return double.tryParse(getLat ? parts[0].trim() : parts[1].trim());
    }

    // You can keep the print statements for your own debugging if you wish
    // print('--- Event Raw Map Data ---');
    // print('id: ${map['id']}');
    // print('eventname: ${map['eventname']}'); // Corrected key
    // print('eventcategory: ${map['eventcategory']}'); // Corrected key
    // print('startdate: ${map['startdate']}'); // Corrected key
    // print('locationName: ${map['locationName']}'); // Corrected key
    // // ... print other fields
    // print('--------------------------');


    return EventModel(
      id: (map['id'] as String?) ?? '',
      eventName: (map['eventname'] as String?) ?? 'Unnamed Event', // CORRECTED: 'event_name' -> 'eventname'
      category: (map['eventcategory'] as String?) ?? 'No Category', // CORRECTED: 'category' -> 'eventcategory'
      description: (map['description'] as String?) ?? 'No description provided.',
      isOnline: (map['is_online'] as bool?) ?? false,
      eventDate: map['startdate'] != null // CORRECTED: 'event_date' -> 'startdate'
          ? DateTime.tryParse(map['startdate'] as String)
          : null,
      eventTime: map['event_time'] as String?,
      eventDuration: map['event_duration'] as int?,
      locationName: (map['locationName'] as String?) ?? 'Unknown Location', // CORRECTED: 'location_name' -> 'locationName'
      locationLat: _parse(map['locationLatLng'] as String?, true),
      locationLng: _parse(map['locationLatLng'] as String?, false),
      isPublic: (map['is_public'] as bool?) ?? true,
      maxAttendees: map['max_attendees'] as int?,
      signUpDeadline: map['sign_up_deadline'] != null
          ? DateTime.tryParse(map['sign_up_deadline'] as String)
          : null,
      creatorUserId: (map['creator_user_id'] as String?) ?? '',
    );
  }
}