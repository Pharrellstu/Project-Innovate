import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/models/report.dart';

class ReportService {
  static final _supabase = Supabase.instance.client;
  static const _table = 'report';

  /// Create a new report
  static Future<ReportModel> create({
    int? giverAccountId,
    int? receiverAccountId,
    String? description,
    String? reportType,
    int? eventId,
  }) async {
    final payload = {
      'giveraccountid'      : giverAccountId,
      'receiveraccount_id'  : receiverAccountId,
      'description'         : description,
      'reporttype'          : reportType,
      'event_id'            : eventId,
    };

    final resp = await _supabase
        .from(_table)
        .insert(payload)
        .select()
        .single();

    return ReportModel.fromMap(resp as Map<String, dynamic>);
  }

  /// Fetch all reports
  static Future<List<ReportModel>> fetchAll() async {
    final rows = await _supabase.from(_table).select();
    return (rows as List)
        .map((r) => ReportModel.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  /// Fetch a report by its PK
  static Future<ReportModel?> fetchById(int id) async {
    final resp = await _supabase
        .from(_table)
        .select()
        .eq('report_id', id)
        .maybeSingle();
    if (resp == null) return null;
    return ReportModel.fromMap(resp as Map<String, dynamic>);
  }

  /// Update an existing report
  static Future<bool> update(ReportModel model) async {
    final rows = await _supabase
        .from(_table)
        .update(model.toMap())
        .eq('report_id', model.reportId)
        .select();
    return (rows as List).isNotEmpty;
  }

  /// Delete a report
  static Future<bool> delete(int id) async {
    final rows = await _supabase
        .from(_table)
        .delete()
        .eq('report_id', id)
        .select();
    return (rows as List).isNotEmpty;
  }
}
