import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../models/schedule_item.dart';

class VacantScheduleCard extends StatelessWidget {
  const VacantScheduleCard({super.key, required this.item});

  final ScheduleItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2A2110)
            : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF5C4A00)
              : const Color(0xFFFDE68A),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time_outlined,
                  color: AppColors.orange, size: 16),
              const SizedBox(width: 4),
              const Expanded(
                child: Text(
                  'Vacant Time Gap',
                  style: TextStyle(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
              ),
              Text(
                item.duration!,
                style: const TextStyle(
                    color: Color(0xFFB45309),
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.time,
            style: const TextStyle(
                color: Color(0xFFD97706),
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            '💡 ${item.recommendation}',
            style: const TextStyle(
                color: Color(0xFFB45309), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
