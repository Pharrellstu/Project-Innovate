import 'package:flutter/material.dart'; // Keep if you use other Flutter specific imports here, otherwise remove
import 'package:intl/intl.dart';

class EventModel {
  final int eventId;
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
  final int? maxnumberofpeople;
  final DateTime? signUpDeadline;
  //final bool offerBadge;
  final String? eventCreatorUUID;
  final String? eventImageUrl;
  final DateTime? createdAt;

  EventModel({
    required this.eventId,
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
    this.maxnumberofpeople,
    this.signUpDeadline,
    this.eventImageUrl,
    //required this.offerBadge,
    required this.eventCreatorUUID,
    required this.createdAt,
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
      eventId: (map['event_id'] as int?) ?? 0,
      eventName: (map['eventname'] as String?) ?? 'Unnamed Event',
      category: (map['eventcategory'] as String?) ?? 'No Category',
      description: (map['eventdescription'] as String?) ?? 'No description provided.',
      isOnline: (map['is_online'] as bool?) ?? false,
      eventDate: map['startdate'] != null
          ? DateTime.tryParse(map['startdate'] as String)
          : null,
      eventTime: map['event_time'] as String?,
      eventDuration: map['event_duration'] as int?,
      locationName: (map['locationName'] as String?) ?? 'Online',
      locationLat: _parse(map['locationLatLng'] as String?, true),
      locationLng: _parse(map['locationLatLng'] as String?, false),
      isPublic: (map['is_public'] as bool?) ?? true,
      maxnumberofpeople: map['maxnumberofpeople'] as int?,
      signUpDeadline: map['sign_up_deadline'] != null
          ? DateTime.tryParse(map['sign_up_deadline'] as String)
          : null,
      eventCreatorUUID: map['eventcreatorid_uuid'] as String?,
      eventImageUrl: map['eventimageurl'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}