import 'package:flutter/material.dart';
import 'package:campuslink/models/user.dart';
import 'package:campuslink/services/user_service.dart';
import 'package:campuslink/services/following_service.dart';
import 'package:campuslink/screens/user_profile_page.dart';

import '../services/auth_gate.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final UserService _userService = UserService();
  final FollowingService _followingService = FollowingService();
  int? _currentUserAccountId = null;
  Future<List<UserObject>> _usersFuture = Future.value([]);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Get current user ID first
    final currentUserId = AuthGate.getCurrentUserId();
    if (currentUserId != null) {
      _currentUserAccountId = await _userService.getAccountIdByAuthUserId(currentUserId);
    }

    // Then load all users
    setState(() {
      _usersFuture = _userService.getAllUsers();
    });
  }

  Future<void> _toggleFollowStatus(UserObject user) async {
    if (_currentUserAccountId == null || user.accountId == null) return;

    final isFollowing = await FollowingService.isFollowing(
      followerId: _currentUserAccountId!,
      followingId: user.accountId!,
    );

    if (isFollowing) {
      await FollowingService.unfollow(
        followerId: _currentUserAccountId!,
        followingId: user.accountId!,
      );
    } else {
      await FollowingService.follow(
        followerId: _currentUserAccountId!,
        followingId: user.accountId!,
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover People'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      body: FutureBuilder<List<UserObject>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load users'),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final users = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserCard(user);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserCard(UserObject user) {
    return FutureBuilder<bool>(
      future: _currentUserAccountId != null && user.accountId != null
          ? FollowingService.isFollowing(
        followerId: _currentUserAccountId!,
        followingId: user.accountId!,
      )
          : Future.value(false),
      builder: (context, snapshot) {
        final isFollowing = snapshot.data ?? false;
        final isCurrentUser = user.accountId == _currentUserAccountId;

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (user.accountId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfilePage(
                      userId: user.accountId!,
                      currentUserAccountId: _currentUserAccountId ?? 0,
                    ),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  // Profile Avatar
                  Stack(
                    clipBehavior: Clip.none, // Allow icon to extend beyond avatar bounds
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: user.profilePictureUrl != null &&
                            user.profilePictureUrl!.isNotEmpty
                            ? NetworkImage(user.profilePictureUrl!)
                            : null,
                        child: user.profilePictureUrl == null ||
                            user.profilePictureUrl!.isEmpty
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      if (!isCurrentUser)
                        Positioned(
                          bottom: -10, // Lower position (negative moves it down)
                          right: -10,  // Keep horizontally centered
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero, // Remove default padding
                              constraints: const BoxConstraints(), // Remove size constraints
                              icon: Icon(
                                isFollowing ? Icons.person_remove : Icons.person_add,
                                color: isFollowing ? Colors.red : Colors.blue,
                                size: 24, // Slightly larger icon
                              ),
                              onPressed: () => _toggleFollowStatus(user),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // User Info
                  Text(
                    user.username ?? 'No username',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (user.nationality?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        user.nationality!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  if (user.bio?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        user.bio!,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: UserSearchDelegate(_userService, _followingService, _currentUserAccountId),
    );
  }
}

class UserSearchDelegate extends SearchDelegate<String> {
  final UserService _userService;
  final FollowingService _followingService;
  final int? _currentUserAccountId;

  UserSearchDelegate(this._userService, this._followingService, this._currentUserAccountId);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<UserObject>>(
      future: _userService.searchUsers(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
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
              ),
              title: Text(user.username ?? ''),
              subtitle: Text(user.email ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () {
                  // Implement follow from search
                },
              ),
              onTap: () {
                close(context, '');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfilePage(
                      userId: user.accountId!,
                      currentUserAccountId: _currentUserAccountId ?? 0,
                    ),
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