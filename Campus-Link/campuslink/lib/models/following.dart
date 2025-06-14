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

  /// Use for insert/update payloads.
  Map<String, dynamic> toMap() {
    return {
      // omit PK on insert to let the DB generate it
      if (followingId != 0) 'following_id': followingId,
      'followepersonid':    followePersonId,
      'followingpersonid':  followingPersonId,
    };
  }
}
