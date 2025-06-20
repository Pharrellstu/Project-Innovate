// lib/widgets/nav_bar.dart
import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final backgroundColor = theme.cardColor;

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: -2,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            index: 0,
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
            color: primaryColor,
          ),
          _NavItem(
            icon: Icons.explore_rounded,
            label: 'Explore',
            index: 1,
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
            color: primaryColor,
          ),
          _NavItem(
            icon: Icons.forum_rounded,
            label: 'Chat',
            index: 2,
            isActive: currentIndex == 2,
            onTap: () => onTap(2),
            color: primaryColor,
          ),
          _NavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            index: 3,
            isActive: currentIndex == 3,
            onTap: () => onTap(3),
            color: primaryColor,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool isActive;
  final VoidCallback onTap;
  final Color color;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.isActive,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (isActive)
                Positioned(
                  top: -4,
                  child: Container(
                    width: 10,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Icon(
                icon,
                size: 28,
                color: isActive ? color : Colors.grey.shade600,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? color : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}