import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../models/campus_location.dart';

class CampusHotspot extends StatelessWidget {
  const CampusHotspot({
    super.key,
    required this.location,
    required this.scale,
    required this.highlighted,
    required this.onTap,
  });

  final CampusLocation location;
  final double scale;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = highlighted ? AppColors.orange : AppColors.primaryGreen;
    return Semantics(
      button: true,
      label: 'Open ${location.name}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: highlighted ? 1.25 : 1,
                duration: const Duration(milliseconds: 160),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bubbleColor,
                    border: Border.all(
                        color: highlighted
                            ? const Color(0xFFFDE68A)
                            : Colors.white,
                        width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: .30),
                          blurRadius: 3,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: const Icon(Icons.location_on,
                      color: Colors.white, size: 8),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                decoration: BoxDecoration(
                    color: bubbleColor.withValues(alpha: .90),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(
                  location.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
