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

  /// Delete a follow record
  static Future<bool> delete(int id) async {
    final rows = await _supabase
        .from(_table)
        .delete()
        .eq('following_id', id)
        .select();
    return (rows as List).isNotEmpty;
  }
}
