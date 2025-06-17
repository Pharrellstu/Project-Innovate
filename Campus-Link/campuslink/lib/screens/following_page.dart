import 'package:campuslink/screens/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:campuslink/models/user.dart';
import 'package:campuslink/services/user_service.dart';
import 'package:campuslink/services/following_service.dart';

class FollowingPage extends StatefulWidget {
  final int accountId;

  const FollowingPage({Key? key, required this.accountId}) : super(key: key);

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  final UserService _userService = UserService();
  final FollowingService _followingService = FollowingService();
  late Future<List<UserObject>> _followingUsersFuture;

  @override
  void initState() {
    super.initState();
    _followingUsersFuture = _fetchFollowingUsers();
  }

  Future<List<UserObject>> _fetchFollowingUsers() async {
    final followingIds = await FollowingService.getFollowingIds(widget.accountId);

    // Fetch all users in parallel
    final users = await Future.wait(
      followingIds.map((id) => _userService.getUserByAccountId(id)),
    );

    return users.whereType<UserObject>().toList();
  }

  Future<void> _unfollowUser(int userId) async {
    await FollowingService.unfollow(
      followerId: widget.accountId,
      followingId: userId,
    );
    setState(() {
      _followingUsersFuture = _fetchFollowingUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Following')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _followingUsersFuture = _fetchFollowingUsers();
          });
        },
        child: FutureBuilder<List<UserObject>>(
          future: _followingUsersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('You are not following anyone yet'));
            }

            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.profilePictureUrl != null &&
                        user.profilePictureUrl!.isNotEmpty
                        ? NetworkImage(user.profilePictureUrl!)
                        : null,
                    child: user.profilePictureUrl == null ||
                        user.profilePictureUrl!.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(user.username ?? 'No username'),
                  subtitle: Text(user.email ?? ''),
                  onTap: () {
                    // Navigate to user profile
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfilePage(
                          userId: user.accountId!,
                          currentUserAccountId: widget.accountId,
                        ),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.person_remove, color: Colors.red),
                    onPressed: () => _unfollowUser(user.accountId!),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}