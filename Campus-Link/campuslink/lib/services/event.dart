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
      return double.tryParse(getLat ? parts[0] : parts[1]);
    }

    return EventModel(
      id: map['id'] as String,
      eventName: map['event_name'] as String,
      category: map['category'] as String?,
      description: map['description'] as String,
      isOnline: map['is_online'] as bool,
      eventDate: map['event_date'] != null
          ? DateTime.parse(map['event_date'] as String)
          : null,
      eventTime: map['event_time'] as String?,
      eventDuration: map['event_duration'] as int?,
      locationName: map['location_name'] as String?,
      locationLat:   _parse(map['locationLatLng'] as String?, true),
      locationLng:   _parse(map['locationLatLng'] as String?, false),
      isPublic: map['is_public'] as bool,
      maxAttendees: map['max_attendees'] as int?,
      signUpDeadline: map['sign_up_deadline'] != null
          ? DateTime.parse(map['sign_up_deadline'] as String)
          : null,
      //offerBadge: map['offer_badge'] as bool,
      creatorUserId: map['creator_user_id'] as String,
    );
  }
}