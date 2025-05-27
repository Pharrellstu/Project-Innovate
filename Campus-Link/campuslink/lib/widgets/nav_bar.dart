import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:campuslink/screens/home_page.dart';
import 'package:campuslink/screens/map_page.dart';
import 'package:campuslink/screens/chat_page.dart';
import 'package:campuslink/screens/profile_page.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(
            context,
            SvgPicture.asset("resources/icons/Home.svg"),
            HomePage(),
          ),
          _navItem(
            context,
            SvgPicture.asset("resources/icons/Map.svg"),
            MapPage(),
          ),
          _navItem(
            context,
            SvgPicture.asset("resources/icons/Chat.svg"),
            ChatPage(),
          ),
          _navItem(
            context,
            SvgPicture.asset("resources/icons/Profile.svg"),
            ProfilePage(),
          ),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, Widget icon, Widget page) {
    return IconButton(
      icon: icon,
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
    );
  }
}
