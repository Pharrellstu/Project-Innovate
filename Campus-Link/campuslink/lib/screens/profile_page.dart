import 'package:flutter/material.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/widgets/top_bar.dart';
import 'edit_profile_page.dart';
import 'even_invitations_page.dart';
import 'package:campuslink/services/profile_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '';
  String nationality = '';
  String bio = '';
  String profilePictureUrl = '';
  List<String> followingImages = [];
  List<String> badgeImages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final profile = await ProfileService.fetchUserProfile();
    final following = await ProfileService.fetchFollowingImages();
    final badges = await ProfileService.fetchBadgeImages();

    if (profile != null && mounted) {
      setState(() {
        name = profile.name;
        nationality = profile.nationality;
        bio = profile.bio;
        profilePictureUrl = profile.profilePictureUrl;
        followingImages = following;
        badgeImages = badges;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const NavBar(),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: TopBar(title: 'Profile view'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
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
                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                            const SizedBox(height: 4),
                            Text('Nationality: $nationality'),
                            const Text('Age: 20'),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: profilePictureUrl.isNotEmpty
                            ? Image.network(profilePictureUrl, width: 80, height: 80, fit: BoxFit.cover)
                            : const Image(
                                image: AssetImage('resources/img/manny-cat-takes-selfies-dogs-gopro-9.webp'),
                                width: 80,
                                height: 80,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(bio),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE6F2FB),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Follow'),
                              Icon(Icons.person_add_alt_1),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditProfilePage()),
                            );

                            if (result != null && mounted) {
                              setState(() {
                                name = result['name'];
                                nationality = result['nationality'];
                                bio = result['bio'];
                                profilePictureUrl = result['profilePictureUrl'];
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile updated')),
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFE6F2FB),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Edit profile',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Icon(Icons.edit, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Following', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: followingImages
                        .map((img) => Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black, width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(img, width: 70, height: 70, fit: BoxFit.cover),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('Earned badges:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: badgeImages
                        .map((img) => ClipOval(
                              child: Image.network(img, width: 75, height: 75, fit: BoxFit.cover),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            ElevatedButton(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventInvitationsPage()),
              );
            },
              child: Text(
                  'Invitations'
              ),
            ),
          ],
        ),
      ),
    );
  }
}
