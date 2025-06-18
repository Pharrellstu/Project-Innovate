// following_service.dart
import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/models/following.dart';

class FollowingService {
  static final _supabase = Supabase.instance.client;
  static const _table = 'following';

  /// Create a new follow relationship
  static Future<FollowingModel> create({
    required int followePersonId,
    required int followingPersonId,
  }) async {
    final payload = {
      'followepersonid':    followePersonId,
      'followingpersonid':  followingPersonId,
    };

    final resp = await _supabase
        .from(_table)
        .insert(payload)
        .select()
        .single();

    return FollowingModel.fromMap(resp as Map<String, dynamic>);
  }

  /// Fetch all follow records
  static Future<List<FollowingModel>> fetchAll() async {
    final rows = await _supabase.from(_table).select();
    return (rows as List)
        .map((r) => FollowingModel.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  /// Fetch one by its PK
  static Future<FollowingModel?> fetchById(int id) async {
    final resp = await _supabase
        .from(_table)
        .select()
        .eq('following_id', id)
        .maybeSingle();
    if (resp == null) return null;
    return FollowingModel.fromMap(resp as Map<String, dynamic>);
  }

  /// Update an existing follow record
  static Future<bool> update(FollowingModel model) async {
    final rows = await _supabase
        .from(_table)
        .update(model.toMap())
        .eq('following_id', model.followingId)
        .select();
    return (rows as List).isNotEmpty;
  }

  /// Get the list of account IDs that a user is following
  static Future<List<int>> getFollowingIds(int followerId) async {
    final response = await _supabase
        .from(_table)
        .select('followingpersonid')
        .eq('followepersonid', followerId);

    return (response as List)
        .map<int>((record) => record['followingpersonid'] as int)
        .toList();
  }

  /// Delete a follow record by primary key
  static Future<bool> delete(int id) async {
    final rows = await _supabase
        .from(_table)
        .delete()
        .eq('following_id', id)
        .select();
    return (rows as List).isNotEmpty;
  }

  /// Check if a follow relationship exists
  static Future<bool> isFollowing({
    required int followerId,
    required int followingId,
  }) async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('followepersonid', followerId)
        .eq('followingpersonid', followingId);

    return response.isNotEmpty;
  }

  /// Unfollow a user by composite key (follower + following)
  static Future<void> unfollow({
    required int followerId,
    required int followingId,
  }) async {
    await _supabase
        .from(_table)
        .delete()
        .eq('followepersonid', followerId)
        .eq('followingpersonid', followingId);
  }

  static Future<int> getFollowingCount(int followerId) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('followepersonid', followerId);

      return response.length;
    } catch (e) {
      log('Error fetching following count: $e');
      return 0;
    }
  }

  /// Get the list of account IDs that are following a user
  static Future<List<int>> getFollowerIds(int userId) async {
    final response = await _supabase
        .from(_table)
        .select('followepersonid')
        .eq('followingpersonid', userId);

    return (response as List)
        .map<int>((record) => record['followepersonid'] as int)
        .toList();
  }

  /// Follow a user
  static Future<void> follow({
    required int followerId,
    required int followingId,
  }) async {
    await _supabase.from(_table).insert({
      'followepersonid': followerId,
      'followingpersonid': followingId,
    });
  }
}