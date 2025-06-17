import 'dart:developer';
import 'package:campuslink/services/supabase_client.dart';
import 'package:campuslink/models/user.dart';
import 'package:campuslink/services/auth_gate.dart';

class UserService {
  final supabase = SupabaseClientProvider.client;

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

  Future<void> updateUserData(String column, dynamic newData) async {
    final userId = AuthGate.getCurrentUserId();
    if (userId == null) throw Exception('No user is logged in');

    try {
      await supabase
          .from('account')
          .update({column: newData})
          .eq('auth_user_id', userId);
    } catch (e) {
      log('Error updating user profile: $e');
    }
  }

  Future<UserObject> getCurrentUser() async {
    final userId = AuthGate.getCurrentUserId();
    if (userId == null) return UserObject.emptyUser;

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
        nationality: response['nationality'] ?? '',
        age: response['age'] ?? 0,
      );
    } catch (e) {
      log('Error fetching user data: $e');
      return UserObject.emptyUser;
    }
  }

  Future<int?> getAccountIdByAuthUserId(String authUserId) async {
    try {
      final response = await supabase
          .from('account')
          .select('accountid')
          .eq('auth_user_id', authUserId)
          .single();

      return response['accountid'] as int?;
    } catch (e) {
      print('Error getting account ID: $e');
      return null;
    }
  }

  Future<List<UserObject>> getAllUsers() async {
    try {
      final response = await supabase
          .from('account')
          .select(); // Fetches all columns for every user

      // Convert each Map in the List to a UserObject
      return response
          .map((userData) => UserObject(
        accountId: userData['accountid'],
        username: userData['username'],
        email: userData['email'],
        studentCardId: userData['studentcardid'],
        isAdmin: userData['isadmin'],
        profilePictureUrl: userData['profilepictureurl'],
        bio: userData['bio'],
        isVerified: userData['isverified'],
        followingCount: userData['followingcount'],
        badgeCount: userData['badgecount'],
        authUserId: userData['auth_user_id'],
          nationality: userData['nationality'] ?? '',
          age: userData['age'] ?? 0
      ))
          .toList();
    } catch (e) {
      log('Error fetching all users: $e');
      return []; // Return empty list on error
    }
  }

  // Add to UserService class

  Future<UserObject?> getUserByAccountId(int accountId) async {
    try {
      final response = await supabase
          .from('account')
          .select()
          .eq('accountid', accountId)
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
        nationality: response['nationality'] ?? '',
        age: response['age'] ?? 0,
      );
    } catch (e) {
      print('Error fetching user by account ID: $e');
      return null;
    }
  }

  // user_service.dart
  Future<UserObject?> getUserByAuthUserId(String authUserId) async {
    try {
      final response = await supabase
          .from('account')
          .select()
          .eq('auth_user_id', authUserId)
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
        nationality: response['nationality'] ?? '',
        age: response['age'] ?? 0,
      );
    } catch (e) {
      print('Error fetching user by auth user ID: $e');
      return null;
    }
  }

  Future<int> getFollowersCount(int accountId) async {
    try {
      final response = await supabase
          .from('follower')
          .select()
          .eq('following_id', accountId);

      return response.length;
    } catch (e) {
      log('Error fetching followers count: $e');
      return 0;
    }
  }

  Future<List<UserObject>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await supabase
          .from('account')
          .select()
          .ilike('username', '%$query%')
          .order('username', ascending: true);

      return response
          .map((userData) => UserObject(
        accountId: userData['accountid'],
        username: userData['username'],
        email: userData['email'],
        studentCardId: userData['studentcardid'],
        isAdmin: userData['isadmin'],
        profilePictureUrl: userData['profilepictureurl'],
        bio: userData['bio'],
        isVerified: userData['isverified'],
        badgeCount: userData['badgecount'],
        authUserId: userData['auth_user_id'],
        nationality: userData['nationality'] ?? '',
        age: userData['age'] ?? 0,
        followingCount: null,
      ))
          .toList();
    } catch (e) {
      log('Error searching users: $e');
      return [];
    }
  }
}
