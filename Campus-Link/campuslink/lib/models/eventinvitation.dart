class EventInvitationModel {
  final int eventInvitationId;
  final int eventId;
  final int receiverAccountId;
  final int eventInvitationCreaterId;

  EventInvitationModel({
    this.eventInvitationId = 0, // Default to 0 for new records
    required this.eventId,
    required this.receiverAccountId,
    required this.eventInvitationCreaterId,
  });

  factory EventInvitationModel.fromMap(Map<String, dynamic> m) {
    return EventInvitationModel(
      eventInvitationId:       m['eventinvitation_id'] as int,
      eventId:                 m['event_id'] as int,
      receiverAccountId:       m['receiveraccount_id'] as int,
      eventInvitationCreaterId: m['eventinvitationcreater_id'] as int,
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