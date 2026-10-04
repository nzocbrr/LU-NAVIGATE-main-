import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../models/schedule_item.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({super.key, required this.item});

  final ScheduleItem item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final borderColor =
        isDark ? AppColors.borderDark : const Color(0xFFE5E7EB);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.subject!,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.primaryGreen.withValues(alpha: .2)
                        : AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.section!,
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _DetailLine(
                icon: Icons.access_time_outlined, text: item.time),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    color: cs.onSurface.withValues(alpha: .5), size: 15),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.room == 'OL'
                        ? 'Online Class'
                        : 'Room: ${item.room}',
                    style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurface.withValues(alpha: .55)),
                  ),
                ),
                Icon(Icons.person_outline,
                    color: cs.onSurface.withValues(alpha: .5), size: 15),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    item.instructor!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurface.withValues(alpha: .55)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon,
            color: cs.onSurface.withValues(alpha: .5), size: 15),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
              fontSize: 13,
              color: cs.onSurface.withValues(alpha: .55)),
        ),
      ],
    );
  }
}
