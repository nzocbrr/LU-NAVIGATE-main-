import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../models/announcement.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.isRead,
    required this.onTap,
    required this.onDismiss,
  });

  final Announcement announcement;
  final bool isRead;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  bool get _emergency =>
      announcement.category == AnnouncementCategory.emergency;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor =
        _emergency ? AppColors.red : AppColors.blue;

    final cardBg = _emergency
        ? (isDark
            ? const Color(0xFF2D1515)
            : const Color(0xFFFFF5F5))
        : isRead
            ? (isDark
                ? AppColors.cardDark
                : const Color(0xFFF3F4F6))
            : (isDark ? AppColors.cardDark : Colors.white);

    final borderColor = _emergency
        ? (isDark
            ? const Color(0xFF7F1D1D)
            : const Color(0xFFFECDD3))
        : (isDark
            ? AppColors.borderDark
            : const Color(0xFFE5E7EB));

    return Opacity(
      opacity: isRead ? .72 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _emergency
                            ? Icons.error
                            : Icons.info,
                        color: categoryColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _emergency
                            ? 'EMERGENCY ALERT'
                            : 'CLASS UPDATE',
                        style: TextStyle(
                            color: categoryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (!isRead) const SizedBox(width: 6),
                      Text(
                        announcement.time,
                        style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface
                                .withValues(alpha: .45)),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: onDismiss,
                        icon: Icon(
                          Icons.close,
                          size: 16,
                          color: cs.onSurface
                              .withValues(alpha: .35),
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minHeight: 20, minWidth: 20),
                        tooltip: 'Dismiss announcement',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    announcement.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isRead
                          ? FontWeight.w500
                          : FontWeight.w700,
                      color: isRead
                          ? cs.onSurface.withValues(alpha: .6)
                          : cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    announcement.body,
                    style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurface.withValues(alpha: .6),
                        height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Divider(
                      height: 1,
                      color: cs.onSurface.withValues(alpha: .08)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Posted by: ${announcement.author}',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface
                                  .withValues(alpha: .45)),
                        ),
                      ),
                      Text(
                        isRead
                            ? 'Mark as unread'
                            : 'Tap to mark read',
                        style: TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: cs.onSurface
                                .withValues(alpha: .35)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
