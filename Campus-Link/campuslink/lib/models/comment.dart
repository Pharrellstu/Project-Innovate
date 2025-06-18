import 'package:campuslink/models/user.dart';

class CommentModel {
  final int commentId;
  final int eventId;
  final int accountId;
  final String commentText;
  final DateTime createdAt;
  UserObject? user; // To hold user details

  CommentModel({
    required this.commentId,
    required this.eventId,
    required this.accountId,
    required this.commentText,
    required this.createdAt,
    this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      commentId: json['comment_id'],
      eventId: json['event_id'],
      accountId: json['account_id'],
      commentText: json['comment_text'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
