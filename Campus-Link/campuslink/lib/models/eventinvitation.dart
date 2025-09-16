class EventInvitationModel {
  final int eventInvitationId;
  final int eventId;
  final int receiverAccountId;
  final int eventInvitationCreaterId;
  final String status;

  EventInvitationModel({
    this.eventInvitationId = 0, // 0 for new records
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
      if (eventInvitationId != 0) 'eventinvitation_id': eventInvitationId,
      'event_id':                 eventId,
      'receiveraccount_id':       receiverAccountId,
      'eventinvitationcreater_id': eventInvitationCreaterId,
    };
  }

  EventInvitationModel withStatus(String newStatus) {
    return EventInvitationModel(
      eventInvitationId: eventInvitationId,
      eventId: eventId,
      receiverAccountId: receiverAccountId,
      eventInvitationCreaterId: eventInvitationCreaterId,
      status: newStatus,
    );
  }
}

extension EventInvitationModelCopyWith on EventInvitationModel {
  EventInvitationModel copyWith({
    int? eventInvitationId,
    int? eventId,
    int? eventInvitationCreaterId,
    int? eventInvitationReceiverId,
    String? status,
  }) {
    return EventInvitationModel(
      eventInvitationId: eventInvitationId ?? this.eventInvitationId,
      eventId: eventId ?? this.eventId,
      eventInvitationCreaterId: eventInvitationCreaterId ?? this.eventInvitationCreaterId,
      receiverAccountId: eventInvitationReceiverId ?? this.receiverAccountId,
      status: status ?? this.status,
    );
  }
}

