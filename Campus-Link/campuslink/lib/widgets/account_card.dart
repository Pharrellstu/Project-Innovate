import 'package:flutter/material.dart';
import 'package:campuslink/screens/profile_page.dart';
import 'package:campuslink/services/auth_gate.dart';
import 'package:campuslink/services/following_service.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.accountImage,
    required this.accountName,
    required this.accountId,
    this.accountCountry = "",
    this.favouriteActivities = "",

  });

  final String accountImage;
  final String accountName;
  final int accountId;
  final String accountCountry;
  final String favouriteActivities;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
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
                    // builder: (context) => ProfilePage(accountId: accountId),
                  ),
                );
              },
              child: PostCardContent(
                accountImage: accountImage,
                accountName: accountName,
                accountCountry: accountCountry,
                favouriteActivities: favouriteActivities,
                accountId: accountId,
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
    required this.accountId,
    this.accountCountry = "",
    this.favouriteActivities = "",
  });

  final String accountImage;
  final int accountId;
  final String accountName;
  final String accountCountry;
  final String favouriteActivities;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 220,
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
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.network(
                  accountImage,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      width: 70,
                      height: 70,
                      child: Center(
                        child: Icon(Icons.broken_image, color: Colors.grey, size: 24),
                      ),
                    );
                  },
                ),
              ),
            )
           else
            Container(
              width: 70,
              height: 70,
              margin: const EdgeInsets.only(right:10, left: 10, top: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Icon(Icons.person, color: Colors.grey),
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
                      final currentUserId = AuthGate.getCurrentUserId();
                      final profileUserId = accountId;
                      // try {
                      //   await FollowingService.create(
                      //     followePersonId: currentUserId,
                      //     followingPersonId: profileUserId,
                      //   );
                      //   // Optionally show a success message or update UI
                      // } catch (e) {
                      //   // Handle error, e.g., show a snackbar
                      // }
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