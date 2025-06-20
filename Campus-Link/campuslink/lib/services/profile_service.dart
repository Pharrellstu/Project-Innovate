import 'dart:developer';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileData {
  final int id;
  final String name;
  final String bio;
  final String profilePictureUrl;
  final String? nationality;
  final int? age;           

  ProfileData({
    required this.id,
    required this.name,
    required this.bio,
    required this.profilePictureUrl,
    this.nationality,
    this.age,       
  });

  factory ProfileData.fromMap(Map<String, dynamic> map) {
    return ProfileData(
      id: map['accountid'] as int,
      name: map['username'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      profilePictureUrl: map['profilepictureurl'] as String? ?? '',
      nationality: map['nationality'] as String?, 
      age: map['age'] as int?,                   
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
      log(' ProfileService: Error fetching current account ID: $e');
      return null;
    }
  }

  static Future<ProfileData?> fetchProfileByAccountId(int accountId) async {
    try {
      final data = await _supabase
          .from(_accountTable)
          .select('accountid, username, bio, profilepictureurl, nationality, age')
          .eq('accountid', accountId)
          .maybeSingle();
      if (data == null) return null;
      return ProfileData.fromMap(data);
    } catch (e) {
      log(' ProfileService: Error fetching profile by account ID ($accountId): $e');
      return null;
    }
  }
  
  static Future<ProfileData?> fetchCurrentLoggedInUserProfile() async {
    final authUserId = getCurrentAuthUserId();
    if (authUserId == null) {
      log(' ProfileService: No authenticated user to fetch profile for.');
      return null;
    }
    try {
      final data = await _supabase
          .from(_accountTable)
          .select('accountid, username, bio, profilepictureurl, nationality, age')
          .eq('auth_user_id', authUserId)
          .maybeSingle();
      if (data == null) return null;
      return ProfileData.fromMap(data);
    } catch (e) {
      log(' ProfileService: Error fetching current logged-in user profile: $e');
      return null;
    }
  }

  static Future<bool> updateProfileData(int accountId, {
    required String name,
    required String bio,
    String? profilePictureUrl,
    String? nationality, 
    int? age,           
  }) async {
    try {
      final updates = <String, dynamic>{
        'username': name,
        'bio': bio,
      };
      if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
        updates['profilepictureurl'] = profilePictureUrl;
      }
      if (nationality != null) { 
        updates['nationality'] = nationality;
      }
      if (age != null) { 
        updates['age'] = age;
      }
      await _supabase.from(_accountTable).update(updates).eq('accountid', accountId);
      return true;
    } catch (e) {
      log(' ProfileService: Error updating profile for account ID ($accountId): $e');
      return false;
    }
  }

  static Future<String?> uploadProfileImage(File imageFile, int accountId) async {
    try {
      final fileName = 'user_${accountId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = fileName;
      await _supabase.storage.from(_profilePicturesBucket).upload(path, imageFile);
      return _supabase.storage.from(_profilePicturesBucket).getPublicUrl(path);
    } catch (e) {
      log(' ProfileService: Error uploading profile image: $e');
      return null;
    }
  }

  static Future<bool> followUser(int followerAccountId, int followingAccountId) async {
    if (followerAccountId == followingAccountId) return false;
    try {
      await _supabase.from(_followingTable).insert({
        'followerpersonid': followerAccountId,
        'followingpersonid': followingAccountId,
      });
      return true;
    } catch (e) {
      log(' ProfileService: Error following user (follower: $followerAccountId, following: $followingAccountId): $e');
      return false;
    }
  }

  static Future<bool> unfollowUser(int followerAccountId, int followingAccountId) async {
    try {
      await _supabase
          .from(_followingTable)
          .delete()
          .eq('followerpersonid', followerAccountId)
          .eq('followingpersonid', followingAccountId);
      return true;
    } catch (e) {
      log(' ProfileService: Error unfollowing user (follower: $followerAccountId, following: $followingAccountId): $e');
      return false;
    }
  }

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
      log(' ProfileService: Error checking follow status: $e');
      return false;
    }
  }

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
          .inFilter('accountid', followingIds);
      return (profiles as List)
          .map<String>((row) => (row['profilepictureurl'] as String?) ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
    } catch (e) {
      log(' ProfileService: Error fetching following profile pictures for account ID ($accountId): $e');
      return [];
    }
  }

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
          .inFilter('badge_id', badgeIds); 
      return (badgeDetails as List)
          .map<String>((row) => (row['badgedescription'] as String?) ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
    } catch (e) {
      log(' ProfileService: Error fetching badge image URLs for account ID ($accountId): $e');
      return [];
    }
  }
}