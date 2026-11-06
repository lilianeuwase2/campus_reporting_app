import 'package:flutter/material.dart';

import '../utils/constants.dart';

// The small coloured status badge (Submitted, In progress, Resolved...),
// used on report cards and the details screen.
// Set onDark to true when it sits on a dark blue background.
class StatusChip extends StatelessWidget {
  final String status;
  final bool onDark;
  const StatusChip({super.key, required this.status, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final color = statusColors[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: onDark ? Colors.white : color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // only as wide as the dot and text
        children: [
          // A small dot in the status colour, so it reads like a badge
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color.shade600,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            statusLabels[status] ?? status,
            style: TextStyle(
              color: color.shade800,
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}
