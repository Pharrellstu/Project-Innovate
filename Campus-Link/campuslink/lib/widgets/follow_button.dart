import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback? onPressed;

  const FollowButton({
    Key? key,
    required this.isFollowing,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define explicit styles for each state to prevent color conflicts
    final followStyle = ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white, // White text/icon on blue background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
    );

    final followingStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.grey[200],
      foregroundColor: Colors.black87, // Black text/icon on grey background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      side: BorderSide(color: Colors.grey[300]!),
    );

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        icon: Icon(
          isFollowing ? Icons.check : Icons.person_add_outlined,
          size: 20,
        ),
        label: Text(
          isFollowing ? 'Following' : 'Follow',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onPressed: onPressed,
        // Apply the correct style based on the isFollowing state
        style: isFollowing ? followingStyle : followStyle,
      ),
    );
  }
}