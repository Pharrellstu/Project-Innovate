import 'package:campuslink/screens/create_event_page.dart';
import 'package:campuslink/screens/edit_profile_page.dart';
import 'package:campuslink/screens/home_page.dart';
import 'package:campuslink/screens/my_events_page.dart';
import 'package:campuslink/screens/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:campuslink/models/user.dart';
import 'package:campuslink/services/user_service.dart';
import 'package:campuslink/services/auth_gate.dart';
import 'package:campuslink/screens/following_page.dart';

import '../services/following_service.dart';
import '../widgets/nav_bar.dart';
import 'even_invitations_page.dart';
import 'followers_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  final FollowingService _followingService = FollowingService();
  late Future<UserObject?> _userFuture;
  late Future<int> _followersFuture;
  late Future<int> _followingFuture; // New future for following count

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userId = AuthGate.getCurrentUserId();
    if (userId != null) {
      _userFuture = _userService.getUserByAuthUserId(userId);
      _userFuture.then((user) {
        if (user != null && user.accountId != null) {
          _followersFuture = _userService.getFollowersCount(user.accountId!);
          _followingFuture = FollowingService.getFollowingCount(user.accountId!);
        } else {
          _followersFuture = Future.value(0);
          _followingFuture = Future.value(0);
        }
      });
    } else {
      _userFuture = Future.value(null);
      _followersFuture = Future.value(0);
      _followingFuture = Future.value(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          )
        ],
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Header
                _buildProfileHeader(user),
                const SizedBox(height: 24),

                // User Info
                _buildUserInfo(user),
                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const NavBar(),
    );
  }

  Widget _buildProfileHeader(UserObject user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
              ],
            ),
            const SizedBox(width: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username ?? 'No username',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FutureBuilder<int>(
                      future: _followersFuture,
                      builder: (context, snapshot) {
                        final count = snapshot.hasData ? snapshot.data! : 0;
                        return _buildCountColumn(count, 'Followers', user);
                      },
                    ),
                    const SizedBox(width: 20),
                    FutureBuilder<int>(
                      future: _followingFuture,
                      builder: (context, snapshot) {
                        final count = snapshot.hasData ? snapshot.data! : 0;
                        return _buildCountColumn(count, 'Following', user);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(user.bio ?? 'No bio available')
      ],
    );
  }

// Update _buildCountColumn method
  Widget _buildCountColumn(int count, String label, UserObject user) {
    return GestureDetector(
      onTap: () {
        if (user.accountId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => label == 'Following'
                  ? FollowingPage(accountId: user.accountId!)
                  : FollowersPage(accountId: user.accountId!),
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: label == 'Following' ? Colors.blue : Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: label == 'Following' ? Colors.blue : Colors.blue,
            ),
          ),
        ],
      ),
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
  
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditProfilePage()),
            );
          },
          child: Row(
            children: [
              Icon(Icons.edit),
              SizedBox(width: 10),
              Text('Edit Profile'),
            ],
          ),
        ),
        // Events dropdown button
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'invitations') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EventInvitationsPage(),
                ),
              );
            } else if (value == 'my_events') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyEventsPage(),
                ),
              );
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'invitations',
              child: ListTile(
                leading: Icon(Icons.mail),
                title: Text('Invitations'),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'my_events',
              child: ListTile(
                leading: Icon(Icons.event_note),
                title: Text('My Events'),
              ),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event, color: Colors.white),
                SizedBox(width: 8),
                Text('Events', style: TextStyle(color: Colors.white)),
                SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }
}