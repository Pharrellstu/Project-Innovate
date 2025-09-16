import 'dart:developer';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/models/message.dart';

class ChatPageService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<int?> fetchPersonaId(String uid) async {
    try {
      final resp = await _supabase
          .from('persona')
          .select('id')
          .eq('auth_uid', uid)
          .single();
      if (resp is Map<String, dynamic>) {
        return resp['id'] as int;
      }
    } catch (e) {
      log('Error fetching persona ID: $e');
    }
    return null;
  }

  /// Fetch messages for chat.
  static Future<List<MessageModel>> fetchMessages(int chatId) async {
    try {
      final response = await _supabase
          .from('message')
          .select(r'''
        *,
        messageattachment:attachment_id (
          fileurl
        )
      ''')
          .eq('chat_id', chatId)
          .order('createdat', ascending: true);

      final rows = response as List<dynamic>;
      return rows
          .map((r) => MessageModel.fromMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Error fetching messages: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> uploadAndRegisterAttachment(File file) async {
    // Upload to Supabase Storage
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split("/").last}';
    await _supabase
        .storage
        .from('chat-attachments')
        .upload(fileName, file);
    final publicUrl = _supabase
        .storage
        .from('chat-attachments')
        .getPublicUrl(fileName);

    final insertRes = await _supabase
        .from('messageattachment')
        .insert({ 'fileurl': publicUrl })
        .select('messageattachment_id, fileurl')
        .single();

    return insertRes as Map<String, dynamic>; 
  }

  static Future<void> insertMessage({
    required int chatId,
    required int enrolledPersonaId,
    required String? messageContent,
    int? attachmentId,
  }) async {
    try {
      final payload = {
        'chat_id': chatId,
        'enrolledpersona': enrolledPersonaId,
        'messagecontent': messageContent,
        'createdat': DateTime.now().toUtc().toIso8601String(),
        'attachment_id': attachmentId,
      };
      await _supabase.from('message').insert(payload);
    } catch (e) {
      log('Error inserting message: $e');
    }
  }

}
