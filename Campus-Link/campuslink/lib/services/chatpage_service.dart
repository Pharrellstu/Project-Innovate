import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/models/message.dart';

class ChatPageService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Given an auth UID, look up the persona's integer ID
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

  /// Fetch messages for a chat, ordered oldest → newest
  static Future<List<MessageModel>> fetchMessages(int chatId) async {
    try {
      final response = await _supabase
          .from('message')
          .select()
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

  /// Insert a new chat message
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


  // static Future<bool> insertMessage({
  //   required int chatId,
  //   required int enrolledPersonaId,
  //   required String? messageContent,
  //   int? attachmentId,
  // }) async {
  //   try {
  //     final payload = {
  //       'chat_id'        : chatId,
  //       'enrolledpersona': enrolledPersonaId,
  //       'messagecontent' : messageContent,
  //       'createdat'      : DateTime.now().toUtc().toIso8601String(),
  //       'attachment_id'  : attachmentId,
  //     };
  //
  //     // Add .select() so you get the inserted row back:
  //     final response = await _supabase
  //         .from('message')
  //         .insert(payload)
  //         .select()
  //         .single();
  //     // Log what Supabase returns
  //     log('insertMessage response: $response');
  //     return true;
  //   } catch (e, stack) {
  //     log('Error inserting message: $e\n$stack');
  //     return false;
  //   }
  // }
}
