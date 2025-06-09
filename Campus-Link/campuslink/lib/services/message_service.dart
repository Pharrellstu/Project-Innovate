import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/models/message.dart';

class MessageService {
  static final _supabase = Supabase.instance.client;
  static const _table = 'message';

  /// Create a new message
  static Future<MessageModel> create({
    required int chatId,
    required int enrolledPersonaId,
    String? messageContent,
    DateTime? createdAt,
    int? attachmentId,
  }) async {
    final payload = {
      'chat_id'        : chatId,
      'enrolledpersona': enrolledPersonaId,
      'messagecontent' : messageContent,
      'createdat'      : createdAt?.toIso8601String(),
      'attachment_id'  : attachmentId,
    };

    final resp = await _supabase
        .from(_table)
        .insert(payload)
        .select()
        .single();

    return MessageModel.fromMap(resp as Map<String, dynamic>);
  }

  /// Fetch all messages
  static Future<List<MessageModel>> fetchAll() async {
    final rows = await _supabase.from(_table).select();
    return (rows as List)
        .map((r) => MessageModel.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  /// Fetch one message by its PK
  static Future<MessageModel?> fetchById(int id) async {
    final resp = await _supabase
        .from(_table)
        .select()
        .eq('message_id', id)
        .maybeSingle();
    if (resp == null) return null;
    return MessageModel.fromMap(resp as Map<String, dynamic>);
  }

  /// Update an existing message
  static Future<bool> update(MessageModel model) async {
    final rows = await _supabase
        .from(_table)
        .update(model.toMap())
        .eq('message_id', model.messageId)
        .select();
    return (rows as List).isNotEmpty;
  }

  /// Delete a message
  static Future<bool> delete(int id) async {
    final rows = await _supabase
        .from(_table)
        .delete()
        .eq('message_id', id)
        .select();
    return (rows as List).isNotEmpty;
  }
}
