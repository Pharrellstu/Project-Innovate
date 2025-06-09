class ReportModel {
  final int reportId;
  final int? giverAccountId;
  final int? receiverAccountId;
  final String? description;
  final String? reportType;
  final int? eventId;

  ReportModel({
    required this.reportId,
    this.giverAccountId,
    this.receiverAccountId,
    this.description,
    this.reportType,
    this.eventId,
  });

  factory ReportModel.fromMap(Map<String, dynamic> m) {
    return ReportModel(
      reportId         : m['report_id']          as int,
      giverAccountId   : m['giveraccountid']     as int?,
      receiverAccountId: m['receiveraccount_id'] as int?,
      description      : m['description']        as String?,
      reportType       : m['reporttype']         as String?,
      eventId          : m['event_id']           as int?,
    );
  }

  /// Use for insert/update payloads.
  Map<String, dynamic> toMap() {
    return {
      // omit PK on insert to let the DB generate it
      if (reportId != 0)      'report_id'          : reportId,
      'giveraccountid'        : giverAccountId,
      'receiveraccount_id'    : receiverAccountId,
      'description'           : description,
      'reporttype'            : reportType,
      'event_id'              : eventId,
    };
  }
}
