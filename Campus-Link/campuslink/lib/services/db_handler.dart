import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/services/auth_gate.dart';
import 'package:campuslink/services/user.dart';
import 'package:campuslink/services/chatlist.dart'; // <-- Import ChatSummary, ChatMessage

class DbHandler {
  static SupabaseClient supabase = Supabase.instance.client;

  Future<void> insertUser(String userId, String email) async {
    try {
      await supabase.from('account').insert({
        'auth_user_id': userId,
        'username': email.split('@')[0],
        'email': email,
      });
    } catch (e) {
      log('Error inserting user: $e');
    }
  }

  static Future<void> updateUserData(String column, dynamic newData) async {
    final userId = AuthGate.getCurrentUserId();
    if (userId == null) {
      throw Exception('No user is logged in');
    }

    try {
      await supabase
          .from('account')
          .update({column: newData})
          .eq('auth_user_id', userId);
    } catch (e) {
      log('Error updating user profile: $e');
    }
  }

  static Future<UserObject> getCurrentUser() async {
    final userId = AuthGate.getCurrentUserId();
    if (userId == null) {
      return UserObject.emptyUser;
    }
    try {
      final response = await supabase
          .from('account')
          .select()
          .eq('auth_user_id', userId)
          .single();

      return UserObject(
        accountId: response['accountid'],
        username: response['username'],
        email: response['email'],
        studentCardId: response['studentcardid'],
        isAdmin: response['isadmin'],
        profilePictureUrl: response['profilepictureurl'],
        bio: response['bio'],
        isVerified: response['isverified'],
        followingCount: response['followingcount'],
        badgeCount: response['badgecount'],
        authUserId: response['auth_user_id'],
      );
    } catch (e) {
      log('Error fetching user data: $e');
      return UserObject.emptyUser;
    }
  }

  /// ✅ Moved ChatSummary model out and kept function
  static Future<List<ChatSummary>> fetchChats() async {
    try {
      final response = await supabase
          .from('chat')
          .select('chat_id, event_id, event(eventname)')
          .order('chat_id', ascending: true);

      final List<dynamic> rows = response as List<dynamic>;
      return rows.map((raw) {
        final row = raw as Map<String, dynamic>;
        final ev = row['event'] as Map<String, dynamic>?;
        return ChatSummary(
          chatId: row['chat_id'] as int,
          eventId: row['event_id'] as int,
          title: ev != null ? ev['eventname'] as String : 'Untitled',
        );
      }).toList();
    } catch (e) {
      log('Error fetching chats: $e');
      return [];
    }
  }

  static Future<int?> insertChatForEvent(int eventId) async {
    try {
      final response = await supabase
          .from('chat')
          .insert({'event_id': eventId})
          .select('chat_id')
          .single();

      return (response as Map<String, dynamic>)['chat_id'] as int;
    } catch (e) {
      log('Error inserting chat: $e');
      return null;
    }
  }

  static Future<List<ChatMessage>> fetchMessages(int chatId) async {
    try {
      final response = await supabase
          .from('message')
          .select()
          .eq('chat_id', chatId)
          .order('createdat', ascending: true);

      final List<dynamic> rows = response as List<dynamic>;
      return rows
          .map((raw) => ChatMessage.fromMap(raw as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Error fetching messages: $e');
      return [];
    }
  }

  static Future<void> insertMessage(
      int chatId,
      String content,
      int enrolledPersona, {
        int? attachmentId,
      }) async {
    try {
      final insertRow = {
        'chat_id': chatId,
        'enrolledpersona': enrolledPersona,
        'messagecontent': content,
        'createdat': DateTime.now().toUtc().toIso8601String(),
        'attachment_id': attachmentId,
      };
      await supabase.from('message').insert(insertRow);
    } catch (e) {
      log('Error inserting message: $e');
    }
  }
}
