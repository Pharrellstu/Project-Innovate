import 'package:flutter/material.dart';
import 'package:campuslink/models/user.dart';
import 'package:campuslink/services/user_service.dart';
import 'package:campuslink/services/following_service.dart';
import 'package:campuslink/widgets/follow_button.dart';

import 'followers_page.dart';
import 'following_page.dart';

class UserProfilePage extends StatefulWidget {
  final int userId;
  final int currentUserAccountId;

  const UserProfilePage({
    Key? key,
    required this.userId,
    required this.currentUserAccountId,
  }) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserService _userService = UserService();
  final FollowingService _followingService = FollowingService();
  late Future<UserObject?> _userFuture;
  late Future<int> _followersFuture;
  late Future<int> _followingFuture;
  late Future<bool> _isFollowingFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    _userFuture = _userService.getUserByAccountId(widget.userId);

    _userFuture.then((user) {
      if (user != null) {
        _followersFuture = _userService.getFollowersCount(user.accountId!);
        _followingFuture = FollowingService.getFollowingCount(user.accountId!);
        _isFollowingFuture = FollowingService.isFollowing(
          followerId: widget.currentUserAccountId,
          followingId: user.accountId!,
        );
      }
    });
  }

  Future<void> _toggleFollowStatus() async {
    final isFollowing = await _isFollowingFuture;

    if (isFollowing) {
      await FollowingService.unfollow(
        followerId: widget.currentUserAccountId,
        followingId: widget.userId,
      );
    } else {
      await FollowingService.follow(
        followerId: widget.currentUserAccountId,
        followingId: widget.userId,
      );
    }

    // Refresh data
    setState(() {
      _loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Link'),
      ),
      body: FutureBuilder<UserObject?>(
        future: _userFuture,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return const Center(child: Text('User not found'));
          }

          final user = userSnapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                _buildProfileHeader(user),
                const SizedBox(height: 24),

                // Follow button
                FutureBuilder<bool>(
                  future: _isFollowingFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final isFollowing = snapshot.data ?? false;
                    return Center(
                      child: FollowButton(
                        isFollowing: isFollowing,
                        onPressed: _toggleFollowStatus,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // User Info
                _buildUserInfo(user),
                const SizedBox(height: 24),

                // Follow Stats
                //_buildFollowStats(user),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserObject user) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: user.profilePictureUrl != null &&
                  user.profilePictureUrl!.isNotEmpty
                  ? NetworkImage(user.profilePictureUrl!)
                  : null,
              child: user.profilePictureUrl == null ||
                  user.profilePictureUrl!.isEmpty
                  ? const Icon(Icons.person, size: 60)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              user.bio ?? 'No bio available',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.username ?? 'No username',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              _buildFollowStats(user),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(UserObject user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Email', user.email),
          _buildInfoRow('Student ID', user.studentCardId?.toString()),
          _buildInfoRow('Nationality', user.nationality),
          if (user.age != null && user.age! > 0)
            _buildInfoRow('Age', user.age.toString()),
          _buildInfoRow('Status', user.isVerified == true ? 'Verified' : 'Not Verified'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? 'Not provided'),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowStats(UserObject user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FutureBuilder<int>(
          future: _followersFuture,
          builder: (context, snapshot) {
            final count = snapshot.hasData ? snapshot.data! : 0;
            return _buildStatColumn(count, 'Followers', user);
          },
        ),
        FutureBuilder<int>(
          future: _followingFuture,
          builder: (context, snapshot) {
            final count = snapshot.hasData ? snapshot.data! : 0;
            return _buildStatColumn(count, 'Following', user);
          },
        ),
      ],
    );
  }

  Widget _buildStatColumn(int count, String label, UserObject user) {
    return GestureDetector(
      onTap: () {
        if (user.accountId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => label == 'Followers'
                  ? FollowersPage(accountId: user.accountId!)
                  : FollowingPage(accountId: user.accountId!),
            ),
          );
        }
      },
      child: Column(
        children: [
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}