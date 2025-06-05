import 'package:campuslink/services/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/widgets/top_bar.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = 'Peter Kapsiar';
  String nationality = 'Slovakia';
  String bio =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed rutrum '
      'laoreet massa, nec fringilla massa. Vivamus molestie odio eget diam dictum feugiat.';

  final List<String> followingImages = List.generate(
    5,
    (_) => 'resources/img/manny-cat-takes-selfies-dogs-gopro-9.webp',
  );

  final List<String> badgeImages = List.generate(
    5,
    (_) => 'resources/img/manny-cat-takes-selfies-dogs-gopro-9.webp',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const NavBar(),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: TopBar(title: 'Profile view'),
      ),
      body: Padding(
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
                const ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  child: Image(
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
                // TEMP LOGOUT BUTTON
                ElevatedButton(
                  onPressed: () {
                    AuthGate.logout(context);
                  },
                  child: const Text('Logout'),
                ),
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
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(),
                        ),
                      );

                      if (result != null && mounted) {
                        setState(() {
                          name = result['name'];
                          nationality = result['nationality'];
                          bio = result['bio'];
                        });
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFE6F2FB),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
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
                          child: Image.asset(img, width: 70, height: 70, fit: BoxFit.cover),
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
              children: badgeImages.asMap().entries.map((entry) {
                int index = entry.key;
                String img = entry.value;

                final List<List<Color>> gradients = [
                  [Colors.orangeAccent, Colors.white],
                  [Colors.lightBlueAccent, Colors.white],
                  [Colors.purpleAccent, Colors.white],
                  [Colors.blueAccent, Colors.white],
                  [Colors.redAccent, Colors.white],
                ];

                return Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradients[index % gradients.length],
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(img, width: 75, height: 75, fit: BoxFit.cover),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
