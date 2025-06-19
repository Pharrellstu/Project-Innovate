import 'dart:developer';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

// Represents the data structure for a user's profile.
class ProfileData {
  final int id;
  final String name;
  final String bio;
  final String profilePictureUrl;
  final String? nationality; // Added
  final int? age;             // Added

  ProfileData({
    required this.id,
    required this.name,
    required this.bio,
    required this.profilePictureUrl,
    this.nationality, // Added
    this.age,         // Added
  });

  factory ProfileData.fromMap(Map<String, dynamic> map) {
    return ProfileData(
      id: map['accountid'] as int,
      name: map['username'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      profilePictureUrl: map['profilepictureurl'] as String? ?? '',
      nationality: map['nationality'] as String?, // Added
      age: map['age'] as int?,                   // Added
    );
  }
}

class ProfileService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _accountTable = 'account';
  static const String _followingTable = 'following';
  static const String _badgeOwnershipTable = 'badgeownership';
  static const String _badgeTable = 'badge';
  static const String _profilePicturesBucket = 'accountimages';

  static String? getCurrentAuthUserId() {
    return _supabase.auth.currentUser?.id;
  }

  // Get the account ID of the currently logged-in Supabase user.
  static Future<int?> getCurrentAccountId() async {
    final authUserId = getCurrentAuthUserId();
    if (authUserId == null) return null;

    try {
      final result = await _supabase
          .from(_accountTable)
          .select('accountid')
          .eq('auth_user_id', authUserId)
          .maybeSingle();
      return result?['accountid'] as int?;
    } catch (e) {
      log('❌ ProfileService: Error fetching current account ID: $e');
      return null;
    }
  }

  // Fetch a user's profile by their account ID.
  static Future<ProfileData?> fetchProfileByAccountId(int accountId) async {
    try {
      final data = await _supabase
          .from(_accountTable)
          .select('accountid, username, bio, profilepictureurl, nationality, age') // Added nationality, age
          .eq('accountid', accountId)
          .maybeSingle();
      if (data == null) return null;
      return ProfileData.fromMap(data);
    } catch (e) {
      log('❌ ProfileService: Error fetching profile by account ID ($accountId): $e');
      return null;
    }
  }
  
  // Fetch the profile of the currently logged-in user.
  static Future<ProfileData?> fetchCurrentLoggedInUserProfile() async {
    final authUserId = getCurrentAuthUserId();
    if (authUserId == null) {
      log('❌ ProfileService: No authenticated user to fetch profile for.');
      return null;
    }
    try {
      final data = await _supabase
          .from(_accountTable)
          .select('accountid, username, bio, profilepictureurl, nationality, age') // Added nationality, age
          .eq('auth_user_id', authUserId)
          .maybeSingle();
      if (data == null) return null;
      return ProfileData.fromMap(data);
    } catch (e) {
      log('❌ ProfileService: Error fetching current logged-in user profile: $e');
      return null;
    }
  }

  // Update profile information for a given account ID.
  static Future<bool> updateProfileData(int accountId, {
    required String name,
    required String bio,
    String? profilePictureUrl,
    String? nationality, // Added
    int? age,             // Added
  }) async {
    try {
      final updates = <String, dynamic>{
        'username': name,
        'bio': bio,
      };
      if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
        updates['profilepictureurl'] = profilePictureUrl;
      }
      if (nationality != null) { // Added
        updates['nationality'] = nationality;
      }
      if (age != null) { // Added
        updates['age'] = age;
      }
      await _supabase.from(_accountTable).update(updates).eq('accountid', accountId);
      return true;
    } catch (e) {
      log('❌ ProfileService: Error updating profile for account ID ($accountId): $e');
      return false;
    }
  }

  // Upload a profile image and return its public URL.
  static Future<String?> uploadProfileImage(File imageFile, int accountId) async {
    try {
      final fileName = 'user_${accountId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = fileName;
      await _supabase.storage.from(_profilePicturesBucket).upload(path, imageFile);
      return _supabase.storage.from(_profilePicturesBucket).getPublicUrl(path);
    } catch (e) {
      log('❌ ProfileService: Error uploading profile image: $e');
      return null;
    }
  }

  // Make the current user (follower) follow another user (followed).
  static Future<bool> followUser(int followerAccountId, int followingAccountId) async {
    if (followerAccountId == followingAccountId) return false;
    try {
      await _supabase.from(_followingTable).insert({
        'followerpersonid': followerAccountId,
        'followingpersonid': followingAccountId,
      });
      return true;
    } catch (e) {
      log('❌ ProfileService: Error following user (follower: $followerAccountId, following: $followingAccountId): $e');
      return false;
    }
  }

  // Make the current user (follower) unfollow another user (followed).
  static Future<bool> unfollowUser(int followerAccountId, int followingAccountId) async {
    try {
      await _supabase
          .from(_followingTable)
          .delete()
          .eq('followerpersonid', followerAccountId)
          .eq('followingpersonid', followingAccountId);
      return true;
    } catch (e) {
      log('❌ ProfileService: Error unfollowing user (follower: $followerAccountId, following: $followingAccountId): $e');
      return false;
    }
  }

  // Check if the current user (follower) is following another user (followed).
  static Future<bool> isFollowing(int followerAccountId, int targetAccountId) async {
    if (followerAccountId == targetAccountId) return false;
    try {
      final result = await _supabase
          .from(_followingTable)
          .select('following_id')
          .eq('followerpersonid', followerAccountId)
          .eq('followingpersonid', targetAccountId)
          .maybeSingle();
      return result != null;
    } catch (e) {
      log('❌ ProfileService: Error checking follow status: $e');
      return false;
    }
  }

  // Get list of profile image URLs for users someone is following
  static Future<List<String>> fetchFollowingProfilePictures(int accountId) async {
    try {
      final followingRows = await _supabase
          .from(_followingTable)
          .select('followingpersonid')
          .eq('followerpersonid', accountId);
      final followingIds = (followingRows as List)
          .map<int>((row) => row['followingpersonid'] as int)
          .toList();
      if (followingIds.isEmpty) return [];
      final profiles = await _supabase
          .from(_accountTable)
          .select('profilepictureurl')
          .inFilter('accountid', followingIds); // Corrected to inFilter
      return (profiles as List)
          .map<String>((row) => (row['profilepictureurl'] as String?) ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
    } catch (e) {
      log('❌ ProfileService: Error fetching following profile pictures for account ID ($accountId): $e');
      return [];
    }
  }

  // Get list of badge image URLs (assuming 'badgedescription' contains the image URL)
  static Future<List<String>> fetchBadgeImageUrls(int accountId) async {
    try {
      final badgeOwnershipRows = await _supabase
          .from(_badgeOwnershipTable)
          .select('badge_id')
          .eq('accountid', accountId);
      final badgeIds = (badgeOwnershipRows as List)
          .map<int>((row) => row['badge_id'] as int)
          .toList();
      if (badgeIds.isEmpty) return [];
      final badgeDetails = await _supabase
          .from(_badgeTable)
          .select('badgedescription')
          .inFilter('badge_id', badgeIds); // Corrected to inFilter
      return (badgeDetails as List)
          .map<String>((row) => (row['badgedescription'] as String?) ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
    } catch (e) {
      log('❌ ProfileService: Error fetching badge image URLs for account ID ($accountId): $e');
      return [];
    }
  }
}