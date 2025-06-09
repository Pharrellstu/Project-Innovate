class EventEnrollmentModel {
  final int eventEnrollmentId;
  final int? accountId;
  final int? eventId;

  EventEnrollmentModel({
    required this.eventEnrollmentId,
    this.accountId,
    this.eventId,
  });

  factory EventEnrollmentModel.fromMap(Map<String, dynamic> m) {
    return EventEnrollmentModel(
      eventEnrollmentId: m['eventenrollment_id'] as int,
      accountId:        m['accountid']           as int?,
      eventId:          m['eventid']             as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // omit the PK if letting the DB generate it on insert:
      if (eventEnrollmentId != 0) 'eventenrollment_id': eventEnrollmentId,
      'accountid': accountId,
      'eventid':   eventId,
    };
  }
}
