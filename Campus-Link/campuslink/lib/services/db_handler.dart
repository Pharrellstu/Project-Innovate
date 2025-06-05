import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/services/auth_gate.dart';
import 'package:campuslink/services/user.dart';

class DbHandler {
  static SupabaseClient supabase = Supabase.instance.client;

  Future<void> insertUser(String userId, String email) async {
    try {
      await supabase.from('account').insert({
        'auth_user_id': userId,
        'username': email.split('@')[0], // TEMP: Use email prefix as username
        'email': email,
      });
    } catch (e) {
      log('Error inserting user: $e');
    }
  }

  // Function to get current user data
  static Future<UserObject> getCurrentUser() async {
    final userId = AuthGate.getCurrentUserId();
    final UserObject selectedUser;
    final Map<String, dynamic> response;

    if (userId == null) {
      return UserObject.emptyUser; // No user is logged in
    }

    try {
      response =
          await supabase
              .from('account')
              .select()
              .eq('auth_user_id', userId)
              .single();

      selectedUser = UserObject(
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
      
      return selectedUser;
    } catch (e) {
      log('Error fetching user data: $e');
      return UserObject.emptyUser;
    }
  }
}
