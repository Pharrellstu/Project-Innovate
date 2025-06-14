import 'package:flutter/material.dart';
import 'package:campuslink/screens/profile_page.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.accountImage,
    required this.accountName,
    this.accountCountry = "",
    this.favouriteActivities = "",
  });

  final String accountImage;
  final String accountName;
  final String accountCountry;
  final String favouriteActivities;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(),
                  ),
                );
              },
              child: PostCardContent(
                accountImage: accountImage,
                accountName: accountName,
                accountCountry: accountCountry,
                favouriteActivities: favouriteActivities,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostCardContent extends StatelessWidget {
  const PostCardContent({
    super.key,
    required this.accountImage,
    required this.accountName,
    this.accountCountry = "",
    this.favouriteActivities = "",
  });

  final String accountImage;
  final String accountName;
  final String accountCountry;
  final String favouriteActivities;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 200,
        maxHeight: 240,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0x190074CE),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (accountImage.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right:10, left: 10, top: 20),
              child: ClipOval(
                child: Image.network(
                  accountImage,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      width: 80,
                      height: 80,
                      child: Center(
                        child: Icon(Icons.broken_image, color: Colors.grey, size: 24),
                      ),
                    );
                  },
                ),
              ),
            ),
          Container(

            margin: const EdgeInsets.only(right:10, left: 10, top: 10, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accountName,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  accountCountry,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  favouriteActivities,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: 30, // 30 pixels for the button
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add follow logic here
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                    ),
                    child: const Text('Follow'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}