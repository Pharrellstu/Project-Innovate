import 'package:campuslink/screens/edit_profile_page.dart';
import 'package:campuslink/screens/my_events_page.dart';
import 'package:campuslink/screens/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:campuslink/models/user.dart';
import 'package:campuslink/services/user_service.dart';
import 'package:campuslink/services/auth_gate.dart';
import 'package:campuslink/screens/following_page.dart';
import '../services/following_service.dart';
import 'even_invitations_page.dart';
import 'followers_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  final FollowingService _followingService = FollowingService();
  late Future<UserObject?> _userFuture;
  late Future<int> _followersFuture;
  late Future<int> _followingFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<UserObject?>(
        future: _userFuture,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          }

          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('User not found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final user = userSnapshot.data!;

          return CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverAppBar(
                title: Text('Profile'),
                titleTextStyle: TextStyle(color: Colors.black, fontSize: 25),
                floating: false,
                pinned: true,
                //backgroundColor: Colors.blue.shade600,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(

                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                      );
                    },
                  ),
                ],
              ),

              // Profile Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                    offset: const Offset(0, 10),
                    child: Column(
                      children: [
                        _buildProfileHeader(user),
                        const SizedBox(height: 20),
                        _buildStatsCard(user),
                        const SizedBox(height: 20),
                        _buildUserInfoCard(user),
                        const SizedBox(height: 20),
                        _buildActionButtons(),
                        const SizedBox(height: 100), // Bottom padding for nav bar
                      ],
                    ),
                  ),
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
          // Profile Picture with Status Ring
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: user.isVerified == true
                      ? const LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                  )
                      : const LinearGradient(
                    colors: [Colors.grey, Colors.grey],
                  ),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 56,
                    backgroundImage: user.profilePictureUrl != null &&
                        user.profilePictureUrl!.isNotEmpty
                        ? NetworkImage(user.profilePictureUrl!)
                        : null,
                    child: user.profilePictureUrl == null ||
                        user.profilePictureUrl!.isEmpty
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
              // Verification Badge
              if (user.isVerified == true)
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Username and Bio
          Text(
            user.username ?? 'No username',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                user.bio!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
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
              final count = snapshot.hasData ? snapshot.data! : 0;
              return _buildStatItem(count, 'Followers', Icons.people, user, false);
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
              final count = snapshot.hasData ? snapshot.data! : 0;
              return _buildStatItem(count, 'Following', Icons.person_add, user, true);
            },
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey[300],
          ),
          _buildStatItem(user.badgeCount ?? 0, 'Badges', Icons.star, user, false),
        ],
      ),
    );
  }

  Widget _buildStatItem(int count, String label, IconData icon, UserObject user, bool isFollowing) {
    return GestureDetector(
      onTap: () {
        if (user.accountId != null && (label == 'Followers' || label == 'Following')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => isFollowing
                  ? FollowingPage(accountId: user.accountId!)
                  : FollowersPage(accountId: user.accountId!),
            ),
          );
        }
      },
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

  Widget _buildUserInfoCard(UserObject user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          _buildInfoTile(Icons.email, 'Email', user.email),
          _buildInfoTile(Icons.badge, 'Student ID', user.studentCardId?.toString()),
          _buildInfoTile(Icons.flag, 'Nationality', user.nationality),
          if (user.age != null && user.age! > 0)
            _buildInfoTile(Icons.cake, 'Age', '${user.age} years old'),
          _buildInfoTile(
            user.isVerified == true ? Icons.verified_user : Icons.person,
            'Status',
            user.isVerified == true ? 'Verified' : 'Not Verified',
            isVerified: user.isVerified == true,
          ),
          if (user.isAdmin == true)
            _buildInfoTile(Icons.admin_panel_settings, 'Role', 'Administrator', isAdmin: true),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String? value, {bool isVerified = false, bool isAdmin = false}) {
    Color iconColor = Colors.grey[600]!;
    Color valueColor = Colors.black87;

    if (isVerified) {
      iconColor = Colors.green;
      valueColor = Colors.green;
    } else if (isAdmin) {
      iconColor = Colors.orange;
      valueColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[100]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'Not provided',
              style: TextStyle(
                color: value != null ? valueColor : Colors.grey[500],
                fontWeight: isVerified || isAdmin ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
              icon: const Icon(Icons.edit, size: 20),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Events dropdown button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade600),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: PopupMenuButton<String>(
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
                    leading: Icon(Icons.mail_outline, color: Colors.blue),
                    title: Text('Event Invitations'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'my_events',
                  child: ListTile(
                    leading: Icon(Icons.event_note, color: Colors.blue),
                    title: Text('My Events'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Events',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, color: Colors.blue.shade600),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}