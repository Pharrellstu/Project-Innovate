// account_card.dart
import 'package:flutter/material.dart';
import 'package:campuslink/screens/profile_page.dart';
import 'package:campuslink/services/auth_gate.dart';
import 'package:campuslink/services/following_service.dart';
import 'package:campuslink/services/profile_service.dart';
import 'package:campuslink/services/user_service.dart';

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

class PostCardContent extends StatefulWidget {
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
  State<PostCardContent> createState() => _PostCardContentState();
}

class _PostCardContentState extends State<PostCardContent> {
  bool _isFollowing = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _checkFollowingStatus();
  }

  Future<void> _checkFollowingStatus() async {
    try {
      final currentAuthUserId = AuthGate.getCurrentUserId();
      if (currentAuthUserId == null) return;

      final userService = UserService();
      final followerAccountId = await userService.getAccountIdByAuthUserId(currentAuthUserId);

      if (followerAccountId != null) {
        final isFollowing = await FollowingService.isFollowing(
          followerId: followerAccountId,
          followingId: widget.accountId,
        );

        if (mounted) {
          setState(() {
            _isFollowing = isFollowing;
          });
        }
      }
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }

  Future<void> _handleFollow() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final currentAuthUserId = AuthGate.getCurrentUserId();
      if (currentAuthUserId == null) return;

      final userService = UserService();
      final followerAccountId = await userService.getAccountIdByAuthUserId(currentAuthUserId);

      if (followerAccountId != null) {
        if (_isFollowing) {
          await FollowingService.unfollow(
            followerId: followerAccountId,
            followingId: widget.accountId,
          );
        } else {
          await FollowingService.create(
            followePersonId: followerAccountId,
            followingPersonId: widget.accountId,
          );
        }

        if (mounted) {
          setState(() {
            _isFollowing = !_isFollowing;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isFollowing
                  ? 'You are now following ${widget.accountName}'
                  : 'You unfollowed ${widget.accountName}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to follow: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

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
          if (widget.accountImage.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right:10, left: 10, top: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.network(
                  widget.accountImage,
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
              child: const ClipOval(
                child: Icon(Icons.person, color: Colors.grey),
              ),
            ),
          Container(
            margin: const EdgeInsets.only(right:10, left: 10, top: 10, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.accountName,
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
                  widget.accountCountry,
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
                  widget.favouriteActivities,
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
                  height: 30,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _handleFollow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFollowing ? Colors.grey : Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(_isFollowing ? 'Following' : 'Follow'),
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