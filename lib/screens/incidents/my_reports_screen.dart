import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/incident_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_card.dart';
import 'incident_details_screen.dart';

// The My reports tab: only the reports this user sent, with a quick count
class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<IncidentProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('My reports')),
      body: _body(context, p),
    );
  }

  Widget _body(BuildContext context, IncidentProvider p) {
    if (p.isLoading) return const Center(child: CircularProgressIndicator());
    if (p.loadError != null) {
      return EmptyState(
        icon: Icons.cloud_off,
        message: p.loadError!,
        actionLabel: 'Try again',
        onAction: p.retry,
      );
    }
    final mine = p.myIncidents;
    if (mine.isEmpty) {
      return const EmptyState(
        icon: Icons.assignment_outlined,
        message: "You haven't reported anything yet.\nTap + to add one.",
      );
    }
    final open = mine.where((i) => !closedStatuses.contains(i.status)).length;
    final resolved = mine.where((i) => i.status == 'resolved').length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 96), // room for Report
      children: [
        Row(
          children: [
            Expanded(
              child: _MiniStat(label: 'Open', value: open, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStat(
                label: 'Resolved',
                value: resolved,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStat(
                label: 'Total',
                value: mine.length,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        for (final incident in mine) ...[
          IncidentCard(
            incident: incident,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => IncidentDetailsScreen(incidentId: incident.id),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

// A small pale-blue box with a number and a label
class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
