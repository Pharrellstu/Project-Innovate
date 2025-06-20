import 'package:flutter/material.dart';
import 'package:campuslink/models/user.dart';
import 'package:campuslink/services/user_service.dart';
import 'package:campuslink/services/following_service.dart';
import 'package:campuslink/screens/user_profile_page.dart';
import '../services/auth_gate.dart';

class FollowingPage extends StatefulWidget {
  final int accountId;

  const FollowingPage({Key? key, required this.accountId}) : super(key: key);

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  // Service for handling following/unfollowing actions.
  final FollowingService _followingService = FollowingService();
  // Service for fetching user data.
  final UserService _userService = UserService();
  // Future that holds the list of users the account is following.
  late Future<List<UserObject>> _followingFuture;
  // Future that holds the account ID of the current logged-in user.
  late Future<int> _currentUserAccountId;

  @override
  void initState() {
    super.initState();
    _followingFuture = _fetchFollowing();
    _currentUserAccountId = _getCurrentUserAccountId();
  }

  Future<int> _getCurrentUserAccountId() async {
    final userId = AuthGate.getCurrentUserId();
    if (userId == null) return 0;
    return await _userService.getAccountIdByAuthUserId(userId) ?? 0;
  }

  Future<List<UserObject>> _fetchFollowing() async {
    final followingIds = await FollowingService.getFollowingIds(
      widget.accountId,
    );

    final users = await Future.wait(
      followingIds.map((id) => _userService.getUserByAccountId(id)),
    );

    return users.whereType<UserObject>().toList();
  }

  Future<void> _unfollowUser(int userId) async {
    final currentUserAccountId = await _currentUserAccountId;
    await FollowingService.unfollow(
      followerId: currentUserAccountId,
      followingId: userId,
    );
    setState(() {
      _followingFuture = _fetchFollowing();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Following')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _followingFuture = _fetchFollowing();
          });
        },
        child: FutureBuilder<List<UserObject>>(
          future: _followingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  widget.accountId == (AuthGate.getCurrentUserId() ?? -1)
                      ? 'You are not following anyone yet'
                      : 'This account isn\'t following anyone',
                ),
              );
            }

            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return FutureBuilder<int>(
                  future: _currentUserAccountId,
                  builder: (context, currentUserSnapshot) {
                    final currentUserAccountId = currentUserSnapshot.data ?? 0;
                    final isCurrentUser =
                        user.accountId == currentUserAccountId;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            user.profilePictureUrl != null &&
                                    user.profilePictureUrl!.isNotEmpty
                                ? NetworkImage(user.profilePictureUrl!)
                                : null,
                      ),
                      title: Text(user.username ?? 'No username'),
                      subtitle: Text(user.email ?? ''),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => UserProfilePage(
                                  userId: user.accountId!,
                                  currentUserAccountId: currentUserAccountId,
                                ),
                          ),
                        );
                      },
                      trailing:
                          isCurrentUser
                              ? null
                              : FutureBuilder<bool>(
                                future: FollowingService.isFollowing(
                                  followerId: currentUserAccountId,
                                  followingId: user.accountId!,
                                ),
                                builder: (context, isFollowingSnapshot) {
                                  if (isFollowingSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    );
                                  }

                                  final isFollowing =
                                      isFollowingSnapshot.data ?? false;
                                  return IconButton(
                                    icon: Icon(
                                      isFollowing
                                          ? Icons.person_remove
                                          : Icons.person_add,
                                      color:
                                          isFollowing
                                              ? Colors.red
                                              : Colors.blue,
                                    ),
                                    onPressed:
                                        () => _unfollowUser(user.accountId!),
                                  );
                                },
                              ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
