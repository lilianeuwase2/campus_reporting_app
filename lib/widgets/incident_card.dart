import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import 'status_chip.dart';

// One report in a list, laid out like the sample design:
//
//   [photo]  Title                     (Submitted)  >
//            location icon  Library, 2nd floor
//            calendar icon  2 hours ago
//
// Reports without a photo show their category icon instead.
class IncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback? onTap; // what happens when the card is tapped
  const IncidentCard({super.key, required this.incident, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.line),
            boxShadow: AppColors.softShadow,
          ),
          child: Row(
            children: [
              _Thumbnail(incident: incident),
              const SizedBox(width: 12),
              // Expanded gives the text all the space that is left,
              // and long text ends with "..." instead of overflowing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _InfoLine(
                      icon: Icons.location_on_outlined,
                      text: incident.location,
                    ),
                    const SizedBox(height: 2),
                    _InfoLine(
                      icon: Icons.calendar_today_outlined,
                      text: timeAgo(incident.createdAt),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // The small status badge: Submitted, In progress, Resolved...
              StatusChip(status: incident.status),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

// The square picture on the left: the report's photo, or its category icon
class _Thumbnail extends StatelessWidget {
  final Incident incident;
  const _Thumbnail({required this.incident});

  static const _size = 64.0;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      categoryIcons[incident.category] ?? Icons.help_outline,
      color: AppColors.primary,
      size: 26,
    );
    final url = incident.photoUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: _size,
        height: _size,
        color: AppColors.tint,
        alignment: Alignment.center,
        child: url == null || url.isEmpty
            ? icon
            : Image.network(
                smallPhotoUrl(url),
                width: _size,
                height: _size,
                fit: BoxFit.cover, // fill the square, cutting the edges
                // While the photo downloads, show the icon
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : icon,
                // If the photo can't load (no internet), show the icon
                errorBuilder: (context, error, stackTrace) => icon,
              ),
      ),
    );
  }
}

// A small grey line of text with an icon in front, e.g. the place or the time
class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.muted),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}
