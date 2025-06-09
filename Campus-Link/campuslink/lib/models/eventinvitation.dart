class EventInvitationModel {
  final int eventInvitationId;
  final int? eventId;
  final int? receiverAccountId;
  final int? eventInvitationCreaterId;

  EventInvitationModel({
    required this.eventInvitationId,
    this.eventId,
    this.receiverAccountId,
    this.eventInvitationCreaterId,
  });

  factory EventInvitationModel.fromMap(Map<String, dynamic> m) {
    return EventInvitationModel(
      eventInvitationId:       m['eventinvitation_id']           as int,
      eventId:                 m['event_id']                     as int?,
      receiverAccountId:       m['receiveraccount_id']           as int?,
      eventInvitationCreaterId: m['eventinvitationcreater_id']   as int?,
    );
  }

  /// Use for insert/update payloads.
  Map<String, dynamic> toMap() {
    return {
      // omit the PK to let the DB generate it on insert:
      if (eventInvitationId != 0) 'eventinvitation_id': eventInvitationId,
      'event_id':                 eventId,
      'receiveraccount_id':       receiverAccountId,
      'eventinvitationcreater_id': eventInvitationCreaterId,
    };
  }
}
