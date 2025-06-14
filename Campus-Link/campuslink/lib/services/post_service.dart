import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/models/post.dart';

class PostService {
  static final _supabase = Supabase.instance.client;
  static const _table = 'post';

  /// Create a new post
  static Future<PostModel> create({
    required String postTopic,
    required String postContent,
    int? postCreatorId,
    int? likeCount,
  }) async {
    final payload = {
      'posttopic':      postTopic,
      'postcontent':    postContent,
      'postcreator_id': postCreatorId,
      'likecount':      likeCount,
    };

    final resp = await _supabase
        .from(_table)
        .insert(payload)
        .select()
        .single();

    return PostModel.fromMap(resp as Map<String, dynamic>);
  }

  /// Fetch all posts
  static Future<List<PostModel>> fetchAll() async {
    final rows = await _supabase.from(_table).select();
    return (rows as List)
        .map((r) => PostModel.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  /// Fetch a post by its PK
  static Future<PostModel?> fetchById(int id) async {
    final resp = await _supabase
        .from(_table)
        .select()
        .eq('post_id', id)
        .maybeSingle();
    if (resp == null) return null;
    return PostModel.fromMap(resp as Map<String, dynamic>);
  }

  /// Update an existing post
  static Future<bool> update(PostModel model) async {
    final rows = await _supabase
        .from(_table)
        .update(model.toMap())
        .eq('post_id', model.postId)
        .select();
    return (rows as List).isNotEmpty;
  }

  /// Delete a post
  static Future<bool> delete(int id) async {
    final rows = await _supabase
        .from(_table)
        .delete()
        .eq('post_id', id)
        .select();
    return (rows as List).isNotEmpty;
  }
}