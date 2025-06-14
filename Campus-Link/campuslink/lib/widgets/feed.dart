import 'package:flutter/material.dart';
import 'package:campuslink/widgets/post_card.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedPageState();
}

class _FeedPageState extends State<Feed> {
  List<dynamic> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts(); // ⬅️ Fetch data when the widget loads
  }

  Future<void> fetchPosts() async {
    // final response = await Supabase.instance.client
    //     .from('posts')
    //     .select()
    //     .order('created_at', ascending: false); // optional sorting

    // Simulating a network request with dummy data
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    final response = [
      {
        'accountImage': 'https://hatrabbits.com/wp-content/uploads/2017/01/random.jpg',
        'accountName': 'Joe Doe',
        'accountCountry': 'Netherlands',
        'favouriteActivities': 'Reading, Hiking, Gaming',

      },
      {
        'accountImage': 'https://hatrabbits.com/wp-content/uploads/2017/01/random.jpg',
        'accountName': 'Joe Doe',
        'accountCountry': 'Netherlands',
        'favouriteActivities': 'Reading, Hiking, Gaming',
      },

      {
        'accountImage': 'https://static.wikia.nocookie.net/zelda_gamepedia_en/images/9/9d/Link_TotK.png',
        'accountName': 'Joe Doe',
        'accountCountry': 'Netherlands',
        'favouriteActivities': 'Reading, Hiking, Gaming',
      },
      {
        'accountImage': 'https://hatrabbits.com/wp-content/uploads/2017/01/random.jpg',
        'accountName': 'Anna P.',
        'accountCountry': 'Germany',
        'favouriteActivities': 'Photography, Cycling',
      },
      {
        'accountImage': 'https://hatrabbits.com/wp-content/uploads/2017/01/random.jpg',
        'accountName': 'Peter V.',
        'accountCountry': 'Canada',
        'favouriteActivities': 'Snowboarding, Reading',
      },
    ];
    // Update the state with the fetched posts
    // Uncomment the above line and comment the below line when using Supabase

    setState(() {
      posts = response;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: fetchPosts, // ⬅️ Called when user pulls down
      child: Scaffold(
        body: GridView.builder(

          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 45,
            crossAxisSpacing: 10,
            mainAxisExtent: 240.0,

          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return PostCard(
              accountImage: post['accountImage'],
              accountName: post['accountName'],
              accountCountry: post["accountCountry"] ?? "",
              favouriteActivities: post['favouriteActivities'] ?? "",
            );
          },
        ),
      ),
    );
  }
}
