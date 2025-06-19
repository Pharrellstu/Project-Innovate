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
  int? _currentUserAccountId;
  Future<List<UserObject>> _usersFuture = Future.value([]);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final currentUserId = AuthGate.getCurrentUserId();
    if (currentUserId != null) {
      _currentUserAccountId = await _userService.getAccountIdByAuthUserId(currentUserId);
    }
    setState(() {
      _usersFuture = _userService.getAllUsers();
    });
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
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load users or no users found.'),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final users = snapshot.data!;
          // Filter out the current user from the list
          final otherUsers = users.where((user) => user.accountId != _currentUserAccountId).toList();

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75, // Adjusted for new card layout
            ),
            itemCount: otherUsers.length,
            itemBuilder: (context, index) {
              final user = otherUsers[index];
              return _buildUserCard(user);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserCard(UserObject user) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: InkWell(
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                    const SizedBox(height: 12),
                    Text(
                      user.username ?? 'No username',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.bio ?? 'No bio available',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildFollowButton(user),
        ],
      ),
    );
  }

  Widget _buildFollowButton(UserObject user) {
    return FutureBuilder<bool>(
      future: _currentUserAccountId != null && user.accountId != null
          ? FollowingService.isFollowing(
        followerId: _currentUserAccountId!,
        followingId: user.accountId!,
      )
          : Future.value(false),
      builder: (context, snapshot) {
        final isFollowing = snapshot.data ?? false;
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? Colors.grey[200] : Theme.of(context).primaryColor,
                foregroundColor: isFollowing ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                if (_currentUserAccountId == null || user.accountId == null) return;

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
                // Rebuild the state to reflect the change
                setState(() {});
              },
              child: Text(isFollowing ? 'Unfollow' : 'Follow'),
            ),
          ),
        );
      },
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: UserSearchDelegate(
        userService: _userService,
        currentUserAccountId: _currentUserAccountId,
      ),
    );
  }
}

class UserSearchDelegate extends SearchDelegate<String> {
  final UserService userService;
  final int? currentUserAccountId;

  UserSearchDelegate({required this.userService, this.currentUserAccountId});

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
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(child: Text('Search for users.'));
    }

    return FutureBuilder<List<UserObject>>(
      future: userService.searchUsers(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        final users = snapshot.data!;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            if (user.accountId == currentUserAccountId) {
              return const SizedBox.shrink(); // Don't show current user in search results
            }
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: user.profilePictureUrl != null &&
                    user.profilePictureUrl!.isNotEmpty
                    ? NetworkImage(user.profilePictureUrl!)
                    : null,
                child: user.profilePictureUrl == null || user.profilePictureUrl!.isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(user.username ?? 'No Name'),
              subtitle: Text(user.bio ?? 'No Bio', maxLines: 1),
              onTap: () {
                close(context, '');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfilePage(
                      userId: user.accountId!,
                      currentUserAccountId: currentUserAccountId ?? 0,
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