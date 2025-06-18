import 'package:campuslink/widgets/explore.dart';
import 'package:flutter/material.dart';
import 'package:campuslink/models/user.dart';
import 'package:campuslink/models/event.dart';
import 'package:campuslink/services/user_service.dart';
import 'package:campuslink/services/event_service.dart';
import 'package:campuslink/services/following_service.dart';
import 'package:campuslink/widgets/follow_button.dart'; // Make sure this import is correct
import 'followers_page.dart';
import 'following_page.dart';
import 'event_page.dart';

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

class _UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  late Future<UserObject?> _userFuture;
  late Future<int> _followersFuture;
  late Future<int> _followingFuture;
  late Future<bool> _isFollowingFuture;
  late TabController _tabController;
  late Future<List<EventModel>> _createdEventsFuture;
  late Future<List<EventModel>> _joinedEventsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    setState(() {
      _userFuture = _userService.getUserByAccountId(widget.userId);

      _userFuture.then((user) {
        if (user != null && mounted) {
          _followersFuture = _userService.getFollowersCount(user.accountId!);
          _followingFuture = FollowingService.getFollowingCount(user.accountId!);
          _isFollowingFuture = FollowingService.isFollowing(
            followerId: widget.currentUserAccountId,
            followingId: user.accountId!,
          );
          _createdEventsFuture =
              EventService.fetchEventsCreatedByUser(user.authUserId!);
          _joinedEventsFuture =
              EventService.fetchEventsJoinedByUser(user.accountId!);
        }
      });
    });
  }

  Future<void> _toggleFollowStatus() async {
    final isCurrentlyFollowing = await FollowingService.isFollowing(
      followerId: widget.currentUserAccountId,
      followingId: widget.userId,
    );

    if (isCurrentlyFollowing) {
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

    if (mounted) {
      setState(() {
        _isFollowingFuture = FollowingService.isFollowing(
          followerId: widget.currentUserAccountId,
          followingId: widget.userId,
        );
        _followersFuture = _userService.getFollowersCount(widget.userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text('Profile',
                    style: TextStyle(color: Colors.black, fontSize: 25)),
                floating: true,
                pinned: true,
                snap: true,
                backgroundColor: Colors.grey[50],
                elevation: 0,
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildProfileHeader(user),
                    const SizedBox(height: 20),
                    _buildStatsCard(user),
                    const SizedBox(height: 20),
                    _buildFollowButton(user),
                    const SizedBox(height: 20),
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Created Events'),
                        Tab(text: 'Joined Events'),
                      ],
                    ),
                  ],
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCreatedEventsList(),
                    _buildJoinedEventsList(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserObject user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 60,
            backgroundImage:
            user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty
                ? NetworkImage(user.profilePictureUrl!)
                : null,
            child: user.profilePictureUrl == null ||
                user.profilePictureUrl!.isEmpty
                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.username ?? 'No username',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 16),
          _buildExtraInfoRow(Icons.email, user.email ?? 'No email'),
          const SizedBox(height: 4),
          _buildExtraInfoRow(Icons.flag, user.nationality ?? 'Not specified'),
          const SizedBox(height: 4),
          if (user.age != null && user.age! > 0)
            _buildExtraInfoRow(Icons.cake, '${user.age} years old'),
        ],
      ),
    );
  }

  Widget _buildExtraInfoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildStatsCard(UserObject user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FutureBuilder<int>(
            future: _followersFuture,
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return _buildStatItem(
                  count,
                  'Followers',
                  Icons.people,
                      () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => FollowersPage(accountId: user.accountId!)));
                  }
              );
            },
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey[300],
          ),
          FutureBuilder<int>(
            future: _followingFuture,
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return _buildStatItem(
                  count,
                  'Following',
                  Icons.person_add,
                      () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => FollowingPage(accountId: user.accountId!)));
                  }
              );
            },
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey[300],
          ),
          _buildStatItem(
              user.badgeCount ?? 0,
              'Badges',
              Icons.star,
                  () {}
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(int count, String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.blue.shade600, size: 24),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFollowButton(UserObject user) {
    return FutureBuilder<bool>(
      future: _isFollowingFuture,
      builder: (context, snapshot) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: FollowButton(
            isFollowing: snapshot.data ?? false,
            // Disable the button while the state is loading
            onPressed: snapshot.connectionState == ConnectionState.done
                ? _toggleFollowStatus
                : null,
          ),
        );
      },
    );
  }

  Widget _buildCreatedEventsList() {
    return FutureBuilder<List<EventModel>>(
      future: _createdEventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No events created yet.'));
        }
        final events = snapshot.data!;
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          padding: const EdgeInsets.all(12),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return EventCard(
              event: event,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventPage(eventId: event.eventId),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildJoinedEventsList() {
    return FutureBuilder<List<EventModel>>(
      future: _joinedEventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No events joined yet.'));
        }
        final events = snapshot.data!;
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          padding: const EdgeInsets.all(12),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return EventCard(
              event: event,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventPage(eventId: event.eventId),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}