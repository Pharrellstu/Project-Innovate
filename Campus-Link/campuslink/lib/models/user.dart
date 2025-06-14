class UserObject {
  final int? accountId;
  final String? username;
  final String? email;
  final int? studentCardId;
  final bool? isAdmin;
  final String? profilePictureUrl;
  final String? bio;
  final bool? isVerified;
  final int? followingCount;
  final int? badgeCount;
  final String? authUserId;

  static final emptyUser = UserObject(
    accountId: 0,
    username: '',
    email: '',
    studentCardId: 0,
    isAdmin: false,
    profilePictureUrl: '',
    bio: '',
    isVerified: false,
    followingCount: 0,
    badgeCount: 0,
    authUserId: '',
  );

  UserObject({
    required this.accountId,
    required this.username,
    required this.email,
    required this.studentCardId,
    required this.isAdmin,
    required this.profilePictureUrl,
    required this.bio,
    required this.isVerified,
    required this.followingCount,
    required this.badgeCount,
    required this.authUserId,
  });
}