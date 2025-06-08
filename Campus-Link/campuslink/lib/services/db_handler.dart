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
}
