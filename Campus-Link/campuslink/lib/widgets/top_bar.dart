import 'package:campuslink/screens/create_event_page.dart';
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isCreateBtnVisible;

  const TopBar({super.key, required this.title, this.isCreateBtnVisible = true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        isCreateBtnVisible ? IconButton(
          onPressed: () {
            // TODO: navigate to create post page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateEventPage()),
            );
          },
          icon: Image.asset("resources/icons/newPostBtn.png"),
        ) : Container(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
