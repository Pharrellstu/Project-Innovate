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
        'posterName': 'John Doe',
        'posterImage': 'https://example.com/john.jpg',
        'postImage': 'https://example.com/post1.jpg',
        'postText': 'This is a sample post text.',
        'postNumLikes': 10,
        'postNumComments': 5,
      },
      {
        'posterName': 'Jane Smith',
        'posterImage': 'https://example.com/jane.jpg',
        'postImage': 'https://example.com/post2.jpg',
        'postText': 'Another sample post text.',
        'postNumLikes': 20,
        'postNumComments': 8,
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
        body: ListView.separated(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return PostCard(
              posterName: post['posterName'],
              posterImage: post['posterImage'],
              postImage: post['postImage'],
              postText: post['postText'],
              postNumLikes: post['postNumLikes'],
              postNumComments: post['postNumComments'],
            );
          },
          separatorBuilder:
              (context, index) => const Divider(
                color: Color(0xFFCBCBCB), // Set the color of the separator
                thickness: 1,
                height: 40, // Space between posts
              ),
        ),
      ),
    );
  }
}
