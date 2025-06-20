class PostModel {
  final int postId;
  final String postTopic;
  final String postContent;
  final int? postCreatorId;
  final int? likeCount;

  PostModel({
    required this.postId,
    required this.postTopic,
    required this.postContent,
    this.postCreatorId,
    this.likeCount,
  });

  factory PostModel.fromMap(Map<String, dynamic> m) {
    return PostModel(
      postId:        m['post_id']        as int,
      postTopic:     m['posttopic']      as String,
      postContent:   m['postcontent']    as String,
      postCreatorId: m['postcreator_id'] as int?,
      likeCount:     m['likecount']      as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (postId != 0) 'post_id': postId,
      'posttopic':       postTopic,
      'postcontent':     postContent,
      'postcreator_id':  postCreatorId,
      'likecount':       likeCount,
    };
  }
}