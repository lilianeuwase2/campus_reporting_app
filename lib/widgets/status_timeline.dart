import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/status_update.dart';
import '../utils/constants.dart';
import 'status_chip.dart';

// A report's progress, top to bottom: when it was submitted,
// then every status change staff made
class StatusTimeline extends StatelessWidget {
  final DateTime? submittedAt;
  final List<StatusUpdate> updates;
  const StatusTimeline({
    super.key,
    required this.submittedAt,
    required this.updates,
  });

  String _format(DateTime? date) => date == null
      ? 'Just now' // the server time hasn't arrived yet
      : DateFormat('d MMM yyyy, HH:mm').format(date);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TimelineEntry(
          status: 'submitted',
          title: 'Report submitted',
          date: _format(submittedAt),
          isLast: updates.isEmpty,
        ),
        for (var i = 0; i < updates.length; i++)
          _TimelineEntry(
            status: updates[i].status,
            title: 'Updated by ${updates[i].updatedByName}',
            date: _format(updates[i].updatedAt),
            note: updates[i].note,
            isLast: i == updates.length - 1,
          ),
      ],
    );
  }
}

// One dot + line on the left, the status and details on the right
class _TimelineEntry extends StatelessWidget {
  final String status;
  final String title;
  final String date;
  final String note;
  final bool isLast;
  const _TimelineEntry({
    required this.status,
    required this.title,
    required this.date,
    this.note = '',
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = statusColors[status] ?? Colors.grey;
    // IntrinsicHeight lets the line on the left grow as tall as the text
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: StatusChip(status: status),
                  ),
                  const SizedBox(height: 4),
                  Text(title, style: theme.textTheme.bodyMedium),
                  Text(date, style: theme.textTheme.bodySmall),
                  if (note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '"$note"',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
