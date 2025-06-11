import 'dart:developer';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileData {
  final String name;
  final String nationality;
  final String bio;
  final String profilePictureUrl;

  ProfileData({
    required this.name,
    required this.nationality,
    required this.bio,
    required this.profilePictureUrl,
  });
}

class ProfileService {
  static final SupabaseClient supabase = Supabase.instance.client;

  // ────────────────────────────────
  // 🔹 READ: For Profile View
  // ────────────────────────────────

  static Future<ProfileData?> fetchUserProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final account = await supabase
          .from('account')
          .select()
          .eq('auth_user_id', user.id)
          .single();

      return ProfileData(
        name: account['username'] ?? '',
        nationality: account['nationality'] ?? '',
        bio: account['bio'] ?? '',
        profilePictureUrl: account['profilepictureurl'] ?? '',
      );
    } catch (e) {
      log('Error fetching user profile: $e');
      return null;
    }
  }

  static Future<List<String>> fetchFollowingImages() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return [];

      final account = await supabase
          .from('account')
          .select('accountid')
          .eq('auth_user_id', user.id)
          .single();

      final accountId = account['accountid'] as int;

      final followingRows = await supabase
          .from('following')
          .select('followingpersonid')
          .eq('followerpersonid', accountId);

      final followIds = (followingRows as List)
          .map<int>((row) => row['followingpersonid'] as int)
          .toList();

      if (followIds.isEmpty) return [];

      final profiles = await supabase
          .from('account')
          .select('profilepictureurl')
          .inFilter('accountid', followIds);

      return (profiles as List)
          .map<String>((row) => row['profilepictureurl'] ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
    } catch (e) {
      log('Error fetching following images: $e');
      return [];
    }
  }

  static Future<List<String>> fetchBadgeImages() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return [];

      final account = await supabase
          .from('account')
          .select('accountid')
          .eq('auth_user_id', user.id)
          .single();

      final accountId = account['accountid'] as int;

      final badgeRows = await supabase
          .from('badgeownership')
          .select('badge_id')
          .eq('accountid', accountId);

      final badgeIds = (badgeRows as List)
          .map<int>((row) => row['badge_id'] as int)
          .toList();

      if (badgeIds.isEmpty) return [];

      final badgeDetails = await supabase
          .from('badge')
          .select('badgedescription') // Replace if using badgeimageurl
          .inFilter('badge_id', badgeIds);

      return (badgeDetails as List)
          .map<String>((row) => row['badgedescription'] ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
    } catch (e) {
      log('Error fetching badge images: $e');
      return [];
    }
  }

  // ────────────────────────────────
  // 🟡 WRITE: For Edit Profile Page
  // ────────────────────────────────

  static Future<Map<String, dynamic>?> getProfileByUserId(String userId) async {
    try {
      final response = await supabase
          .from('account')
          .select()
          .eq('auth_user_id', userId)
          .single();
      return response;
    } catch (e) {
      log('Error fetching profile: $e');
      return null;
    }
  }

  static Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'profile_pictures/$fileName';

      await supabase.storage.from('profile_pictures').upload(path, imageFile);
      final publicUrl = supabase.storage.from('profile_pictures').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      log('Error uploading image: $e');
      return null;
    }
  }

  static Future<bool> updateProfile(int accountId, Map<String, dynamic> updates) async {
    try {
      await supabase
          .from('account')
          .update(updates)
          .eq('accountid', accountId);
      return true;
    } catch (e) {
      log('Error updating profile: $e');
      return false;
    }
  }
}
