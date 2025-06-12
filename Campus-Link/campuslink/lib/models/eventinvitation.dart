class EventInvitationModel {
  final int eventInvitationId;
  final int eventId;
  final int receiverAccountId;
  final int eventInvitationCreaterId;
  final String status;

  EventInvitationModel({
    this.eventInvitationId = 0, // Default to 0 for new records
    required this.eventId,
    required this.receiverAccountId,
    required this.eventInvitationCreaterId,
    this.status = 'pending',
  });

  factory EventInvitationModel.fromMap(Map<String, dynamic> m) {
    return EventInvitationModel(
      eventInvitationId:       m['eventinvitation_id'] as int,
      eventId:                 m['event_id'] as int,
      receiverAccountId:       m['receiveraccount_id'] as int,
      eventInvitationCreaterId: m['eventinvitationcreater_id'] as int,
      status:                  m['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // Only include ID for updates, not for inserts
      if (eventInvitationId != 0) 'eventinvitation_id': eventInvitationId,
      'event_id':                 eventId,
      'receiveraccount_id':       receiverAccountId,
      'eventinvitationcreater_id': eventInvitationCreaterId,
    };
  }
}

// 1. Add this extension to your EventInvitationModel
extension EventInvitationModelCopyWith on EventInvitationModel {
  EventInvitationModel copyWith({
    int? eventInvitationId,
    int? eventId,
    int? eventInvitationCreaterId,
    int? eventInvitationReceiverId,
    String? status,
    // Add other properties as needed
  }) {
    return EventInvitationModel(
      eventInvitationId: eventInvitationId ?? this.eventInvitationId,
      eventId: eventId ?? this.eventId,
      eventInvitationCreaterId: eventInvitationCreaterId ?? this.eventInvitationCreaterId,
      receiverAccountId: eventInvitationReceiverId ?? this.receiverAccountId,
      status: status ?? this.status,
      // Copy other properties
    );
  }
}

// 2. Modify your _respondToInvitation method
