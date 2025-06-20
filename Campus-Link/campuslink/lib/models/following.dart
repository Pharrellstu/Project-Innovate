class FollowingModel {
  final int followingId;
  final int? followePersonId;
  final int? followingPersonId;

  FollowingModel({
    required this.followingId,
    this.followePersonId,
    this.followingPersonId,
  });

  factory FollowingModel.fromMap(Map<String, dynamic> m) {
    return FollowingModel(
      followingId:        m['following_id']        as int,
      followePersonId:    m['followepersonid']     as int?,
      followingPersonId:  m['followingpersonid']   as int?,
    );
  }

  /// insert/update payloads.
  Map<String, dynamic> toMap() {
    return {
      if (followingId != 0) 'following_id': followingId,
      'followepersonid':    followePersonId,
      'followingpersonid':  followingPersonId,
    };
  }
}
