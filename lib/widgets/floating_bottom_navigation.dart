import 'dart:ui';

import 'package:flutter/material.dart';

import '../app_colors.dart';

class FloatingBottomNavigation extends StatelessWidget {
  const FloatingBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = <_NavigationItem>[
    _NavigationItem('Map', Icons.map_outlined, Icons.map),
    _NavigationItem('Schedule', Icons.calendar_month_outlined, Icons.calendar_month),
    _NavigationItem('Alerts', Icons.campaign_outlined, Icons.campaign),
    _NavigationItem('Profile', Icons.person_outline, Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.cardDark.withValues(alpha: .92)
        : Colors.white.withValues(alpha: .95);

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: bgColor,
          elevation: 0,
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark ? AppColors.borderDark : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final selected = currentIndex == index;
                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(32),
                    onTap: () => onTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              selected ? item.activeIcon : item.icon,
                              key: ValueKey(selected),
                              color: selected ? cs.primary : AppColors.iosGray,
                              size: 23,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: selected ? cs.primary : AppColors.iosGray,
                              fontSize: 10,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem(this.label, this.icon, this.activeIcon);

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
