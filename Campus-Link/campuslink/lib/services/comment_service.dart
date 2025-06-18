import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comment.dart';
import '../models/user.dart';
import 'user_service.dart';

class CommentService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api/comments';

  // Fetch comments for a specific event
  static Future<List<CommentModel>> getCommentsForEvent(int eventId) async {
    final response = await http.get(Uri.parse('$_baseUrl/event/$eventId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<CommentModel> comments =
          data.map((json) => CommentModel.fromJson(json)).toList();

      // Fetch user details for each comment
      for (var comment in comments) {
        comment.user = await UserService().getUserByAccountId(
          comment.accountId,
        );
      }
      return comments;
    } else {
      throw Exception('Failed to load comments');
    }
  }

  // Post a new comment
  static Future<CommentModel> postComment(
    int eventId,
    int accountId,
    String commentText,
  ) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'event_id': eventId,
        'account_id': accountId,
        'comment_text': commentText,
      }),
    );

    if (response.statusCode == 201) {
      return CommentModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to post comment');
    }
  }

  // Delete a comment
  static Future<void> deleteComment(int commentId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$commentId'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete comment');
    }
  }
}
