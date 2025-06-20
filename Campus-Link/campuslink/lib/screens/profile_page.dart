// Note: This page might be deprecated. The main navigation uses 'profile_page_update.dart'.

import 'package:campuslink/screens/my_events_page.dart';
import 'package:flutter/material.dart';
import 'package:campuslink/services/profile_service.dart';
import 'package:campuslink/widgets/top_bar.dart';
import 'edit_profile_page.dart';
import 'even_invitations_page.dart'; // Assuming this is the correct path
import 'dart:developer'; // For log messages

class ProfilePage extends StatefulWidget {
  final int? viewedAccountId; // If null, shows current logged-in user's profile

  const ProfilePage({super.key, this.viewedAccountId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileData? _profileData;
  List<String> _followingImages = [];
  List<String> _badgeImages = [];

  bool _isLoading = true;
  bool _isOwnProfile = false;
  int? _loggedInAccountId;
  bool _isCurrentlyFollowing = false;

  @override
  void initState() {
    super.initState();
    _initializeProfilePage();
  }

  Future<void> _initializeProfilePage() async {
    setState(() => _isLoading = true);
    _loggedInAccountId = await ProfileService.getCurrentAccountId();

    final accountIdToFetch = widget.viewedAccountId ?? _loggedInAccountId;

    if (accountIdToFetch == null) {
      log('ProfilePage: Could not determine account ID to fetch.');
      if (mounted) setState(() => _isLoading = false);
      // Optionally show an error message to the user
      return;
    }

    _isOwnProfile = _loggedInAccountId == accountIdToFetch;

    // Fetch profile data
    if (_isOwnProfile && widget.viewedAccountId == null) {
      _profileData = await ProfileService.fetchCurrentLoggedInUserProfile();
    } else {
      _profileData = await ProfileService.fetchProfileByAccountId(
        accountIdToFetch,
      );
    }

    if (_profileData != null) {
      // Fetch related data only if profile was loaded successfully
      _followingImages = await ProfileService.fetchFollowingProfilePictures(
        accountIdToFetch,
      );
      _badgeImages = await ProfileService.fetchBadgeImageUrls(accountIdToFetch);

      if (!_isOwnProfile && _loggedInAccountId != null) {
        _isCurrentlyFollowing = await ProfileService.isFollowing(
          _loggedInAccountId!,
          accountIdToFetch,
        );
      }
    } else {
      log(
        'ProfilePage: Failed to load profile data for account ID $accountIdToFetch',
      );
      // Optionally show an error message to the user
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleFollowToggle() async {
    if (_loggedInAccountId == null || _profileData == null || _isOwnProfile)
      return;

    setState(() => _isLoading = true); // Show loading for follow action
    bool success;
    if (_isCurrentlyFollowing) {
      success = await ProfileService.unfollowUser(
        _loggedInAccountId!,
        _profileData!.id,
      );
    } else {
      success = await ProfileService.followUser(
        _loggedInAccountId!,
        _profileData!.id,
      );
    }

    if (success) {
      setState(() {
        _isCurrentlyFollowing = !_isCurrentlyFollowing;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update follow status.')),
        );
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );
    if (result == true && mounted) {
      // Check if update was successful
      _initializeProfilePage(); // Refresh profile data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: TopBar(
          title:
              _isOwnProfile ? 'My Profile' : (_profileData?.name ?? 'Profile'),
          isCreateBtnVisible: false,
          isLogoutBtnVisible: true,
        ),
      ),

      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _profileData == null
              ? const Center(
                child: Text('Could not load profile. Please try again.'),
              )
              : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    // Default image if URL is empty or null
    ImageProvider profileImage = const AssetImage(
      'resources/img/profile-icon-9.png',
    ); // Ensure this asset exists
    if (_profileData!.profilePictureUrl.isNotEmpty) {
      // Try to load network image, fall back to default on error
      profileImage = NetworkImage(_profileData!.profilePictureUrl);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profileData!.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_profileData!.nationality != null &&
                        _profileData!.nationality!.isNotEmpty) ...[
                      Text(
                        'Nationality: ${_profileData!.nationality!}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (_profileData!.age != null) ...[
                      Text(
                        'Age: ${_profileData!.age}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8), // Reduced from 16
              ClipRRect(
                // Changed from CircleAvatar to ClipRRect
                borderRadius: BorderRadius.circular(
                  12.0,
                ), // Adjust radius for less roundness
                child: Image(
                  image: profileImage,
                  width: 68, // Reduced from 80
                  height: 68, // Reduced from 80
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_profileData!.profilePictureUrl.isNotEmpty &&
                              profileImage is NetworkImage)
                          ? (context, error, stackTrace) {
                            log(
                              'Error loading profile image: ${_profileData!.profilePictureUrl}, $error',
                            );
                            // Fallback to default asset if network image fails
                            return Image.asset(
                              'resources/img/profile-icon-9.png',
                              width: 68,
                              height: 68,
                              fit: BoxFit.cover,
                            ); // Adjusted size
                          }
                          : null,
                  // If profilePictureUrl is empty, show default icon within ClipRRect
                  frameBuilder: (
                    context,
                    child,
                    frame,
                    wasSynchronouslyLoaded,
                  ) {
                    if (wasSynchronouslyLoaded) return child;
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeOut,
                      child: child,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _profileData!.bio.isNotEmpty
                ? _profileData!.bio
                : 'No bio available.',
          ),
          const SizedBox(height: 24),
          if (_isOwnProfile)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    onPressed: _navigateToEditProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Spacing between buttons
                Expanded(
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
                    itemBuilder:
                        (BuildContext context) => [
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(Icons.arrow_drop_down, color: Colors.white),
                          Text('Events', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          else if (_loggedInAccountId !=
              null) // Show follow/unfollow only if a user is logged in
            ElevatedButton.icon(
              icon: Icon(
                _isCurrentlyFollowing ? Icons.person_remove : Icons.person_add,
              ),
              label: Text(_isCurrentlyFollowing ? 'Unfollow' : 'Follow'),
              onPressed: _handleFollowToggle,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isCurrentlyFollowing ? Colors.grey : Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          const SizedBox(height: 24),
          _buildSectionTitle('Following'), // Removed count from here
          _buildImageGrid(_followingImages),
          const SizedBox(height: 24),
          _buildSectionTitle('Badges'), // Removed count from here
          _buildImageGrid(_badgeImages, isCircle: true),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildImageGrid(List<String> imageUrls, {bool isCircle = false}) {
    if (imageUrls.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text('Nothing to show here yet.'),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        final imageUrl = imageUrls[index];
        Widget imageDisplayWidget;

        if (imageUrl.isEmpty) {
          imageDisplayWidget = const Icon(
            Icons.person,
            size: 40,
          ); // Default for empty URL
        } else {
          imageDisplayWidget = Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              log('Error loading image in grid: $imageUrl, $error');
              return const Icon(
                Icons.broken_image,
                size: 40,
              ); // Placeholder for failed image
            },
          );
        }

        if (isCircle) {
          // For badges, use CircleAvatar with error handling for NetworkImage
          return CircleAvatar(
            radius: 35,
            backgroundColor: Colors.grey[300], // Background for error/loading
            backgroundImage:
                imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
            onBackgroundImageError:
                imageUrl.isNotEmpty
                    ? (exception, stackTrace) {
                      log('Error loading badge image: $imageUrl, $exception');
                      // The CircleAvatar will show its child or background color on error
                    }
                    : null,
            child:
                imageUrl.isEmpty
                    ? const Icon(Icons.shield, size: 30)
                    : null, // Default icon if URL is empty
          );
        } else {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageDisplayWidget,
          );
        }
      },
    );
  }
}
