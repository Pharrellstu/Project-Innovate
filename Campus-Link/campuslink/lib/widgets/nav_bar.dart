// lib/widgets/nav_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10), // Adjusted padding
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFCBCBCB), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(
            context,
            iconPath: "resources/icons/Home.svg",
            label: 'Home',
            index: 0,
          ),
          _navItem(
            context,
            iconPath: "resources/icons/Map.svg",
            label: 'Map',
            index: 1,
          ),
          _navItem(
            context,
            iconPath: "resources/icons/Chat.svg",
            label: 'Chat',
            index: 2,
          ),
          _navItem(
            context,
            iconPath: "resources/icons/Profile.svg",
            label: 'Profile',
            index: 3,
          ),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, {required String iconPath, required String label, required int index}) {
    final bool isActive = currentIndex == index;
    final Color iconColor = isActive ? Theme.of(context).primaryColor : Colors.grey.shade600;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.translucent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                iconPath,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 12,
                color: iconColor,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}