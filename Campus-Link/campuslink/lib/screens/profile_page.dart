import 'package:flutter/material.dart';


class ProfilePage extends StatelessWidget {
  final List<String> followingImages = [
    'resources/img/manny-cat-takes-selfies-dogs-gopro-9.webp',
    'resources/img/manny-cat-takes-selfies-dogs-gopro-9.webp',
    'resources/img/manny-cat-takes-selfies-dogs-gopro-9.webp',
    'resources/img/manny-cat-takes-selfies-dogs-gopro-9.webp',
    'resources/img/manny-cat-takes-selfies-dogs-gopro-9.webp',
  ];

  final List<String> badgeImages = [
    'resources/img/manny-cat-takes-selfies-dogs-gopro-9.webp',
    'resources/img/manny-cat-takes-selfies-dogs-gopro-9.webp',
    'resources/img/manny-cat-takes-selfies-dogs-gopro-9.webp',
    'resources/img/manny-cat-takes-selfies-dogs-gopro-9.webp',
    'resources/img/manny-cat-takes-selfies-dogs-gopro-9.webp',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Spacer(),
                  Icon(Icons.add),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Peter Kapsiar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                        SizedBox(height: 4),
                        Text('Nationality: Slovakia'),
                        Text('Age: 20'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset('resources/img/manny-cat-takes-selfies-dogs-gopro-9.webp', width: 80, height: 80),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Bio: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed rutrum laoreet massa, nec fringilla massa. Vivamus molestie odio eget diam dictum feugiat.',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Follow'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE6F2FB),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4), // Smaller = less round
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE6F2FB),
                        foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4), // Smaller = less round
                          ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Following', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: followingImages.length,
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(followingImages[index], width: 70, height: 70),
                  ),
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Earned badges:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: badgeImages
                    .map((img) => ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(img, width: 60, height: 60),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
