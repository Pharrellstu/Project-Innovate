import 'package:flutter/material.dart';
import 'package:campuslink/widgets/nav_bar.dart';
import 'package:campuslink/widgets/top_bar.dart';
import 'package:campuslink/widgets/post_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  final String title = "Explore Page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: title),
      bottomNavigationBar: NavBar(),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 5, // Replace with your real data length
        itemBuilder: (context, index) => const PostCard(
          posterName: "John Doe",
          posterImage: "assets/images/poster_image.png",
          postImage: "assets/images/post_image.png",
          postText: "This is a sample post text.",
          postNumLikes: 100,
          postNumComments: 20,
        ),
      ),
    );
  }
}