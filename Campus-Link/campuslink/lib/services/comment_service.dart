import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/models/comment.dart';

class CommentService {
  static final _supabase = Supabase.instance.client;
  static const _table = 'comment';

  /// new comment Creation
  static Future<CommentModel> create({
    int? commentCreator,
    int? postId,
    required String content,
  }) async {
    final payload = {
      'commentcreator': commentCreator,
      'post_id':        postId,
      'content':        content,
    };

    final resp = await _supabase
        .from(_table)
        .insert(payload)
        .select()
        .single();

    return CommentModel.fromMap(resp as Map<String, dynamic>);
  }

  /// Fetch all comments
  static Future<List<CommentModel>> fetchAll() async {
    final rows = await _supabase.from(_table).select();
    return (rows as List)
        .map((r) => CommentModel.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  /// Fetch comments by post
  static Future<List<CommentModel>> fetchByPostId(int postId) async {
    final rows = await _supabase
        .from(_table)
        .select()
        .eq('post_id', postId);
    return (rows as List)
        .map((r) => CommentModel.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  /// Fetch comment by its PK
  static Future<CommentModel?> fetchById(int id) async {
    final resp = await _supabase
        .from(_table)
        .select()
        .eq('comment_id', id)
        .maybeSingle();
    if (resp == null) return null;
    return CommentModel.fromMap(resp as Map<String, dynamic>);
  }

  /// Update an existing comment
  static Future<bool> update(CommentModel model) async {
    final rows = await _supabase
        .from(_table)
        .update(model.toMap())
        .eq('comment_id', model.commentId)
        .select();
    return (rows as List).isNotEmpty;
  }

  /// Delete a comment
  static Future<bool> delete(int id) async {
    final rows = await _supabase
        .from(_table)
        .delete()
        .eq('comment_id', id)
        .select();
    return (rows as List).isNotEmpty;
  }
}
