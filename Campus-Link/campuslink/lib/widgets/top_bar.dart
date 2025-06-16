import 'package:campuslink/screens/create_event_page.dart';
import 'package:campuslink/services/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isCreateBtnVisible;
  final bool isLogoutBtnVisible;

  const TopBar({
    super.key,
    required this.title,
    this.isCreateBtnVisible = true,
    this.isLogoutBtnVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        isCreateBtnVisible
            ? IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateEventPage()),
                );
              },
              icon: Image.asset("resources/icons/newPostBtn.png"),
            )
            : Container(),
        isLogoutBtnVisible
            ? IconButton(
              onPressed: () {
                AuthGate.logout(context);
              },
              icon: SvgPicture.asset("resources/icons/signOut.svg"),
            )
            : Container(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
