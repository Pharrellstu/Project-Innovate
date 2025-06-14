class CommentModel {
  final int commentId;
  final int? commentCreator;
  final int? postId;
  final String content;

  CommentModel({
    required this.commentId,
    this.commentCreator,
    this.postId,
    required this.content,
  });

  factory CommentModel.fromMap(Map<String, dynamic> m) {
    return CommentModel(
      commentId:      m['comment_id']       as int,
      commentCreator: m['commentcreator']   as int?,
      postId:         m['post_id']          as int?,
      content:        m['content']          as String,
    );
  }

  /// Use this for insert/update payloads.
  Map<String, dynamic> toMap() {
    return {
      // omit PK for insert to let DB generate it
      if (commentId != 0) 'comment_id': commentId,
      'commentcreator': commentCreator,
      'post_id':        postId,
      'content':        content,
    };
  }
}