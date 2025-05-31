import 'package:campuslink/screens/post_page.dart';
import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.posterName,
    required this.posterImage,
    required this.postImage,
    required this.postText,
    required this.postNumLikes,
    required this.postNumComments,
  });

  final String posterName;
  final String posterImage;
  final String postImage;
  final String postText;
  final int postNumLikes;
  final int postNumComments;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostCardHeader(posterName: posterName, posterImage: posterImage),
            PostCardContent(
              postImage: postImage,
              postText: postText,
              postNumLikes: postNumLikes,
              postNumComments: postNumComments,
            ),
          ],
        ),
      ),
    );
  }
}

class PostCardHeader extends StatelessWidget {
  const PostCardHeader({
    super.key,
    required this.posterName,
    required this.posterImage,
  });

  final String posterName;
  final String posterImage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          spacing: 5,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(posterImage),
              radius: 20,
            ),
            Text(
              posterName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            // Add your follow button logic here
          },
          child: const Text(
            'View Profile',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }
}

class PostCardContent extends StatelessWidget {
  const PostCardContent({
    super.key,
    required this.postImage,
    required this.postText,
    required this.postNumLikes,
    required this.postNumComments,
  });

  final String postImage;
  final String postText;
  final int postNumLikes;
  final int postNumComments;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0x190074CE),
      ),
      child: GestureDetector(
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              // TODO: add arguments later
              builder: (context) => PostPage(), // Navigate to PostPage 
            ),
          ),
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Post image - if available
            if (postImage.isNotEmpty)
              Container(
                width: double.infinity,
                decoration: ShapeDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/390x230"),
                    fit: BoxFit.fitWidth,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            // Post main text
            Container(
              margin: const EdgeInsets.all(10),
              child: Column(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    postText,
                    // textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Kantumruy Pro',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Post stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$postNumLikes likes - $postNumComments comments',
                        style: TextStyle(
                          color: const Color(0xFFBBBBBB),
                          fontSize: 12,
                          fontFamily: 'Kantumruy Pro',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Tap to view more',
                        style: TextStyle(
                          color: const Color(0xFFBBBBBB),
                          fontSize: 12,
                          fontFamily: 'Kantumruy Pro',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
