import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/incident_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_card.dart';
import '../incidents/incident_details_screen.dart';

// Staff only: how many reports are at each stage, and which still need action.
// MainShell only shows this tab when the logged-in user's role is "staff".
class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<IncidentProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Staff dashboard')),
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
    final counts = p.statusCounts;
    final open = p.openIncidents;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        // The blue summary card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.headerGradient,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${open.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      open.length == 1
                          ? 'report needs action'
                          : 'reports need action',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_late_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // One tile per status, three per row
        LayoutBuilder(
          builder: (context, constraints) {
            final width = ((constraints.maxWidth - 20) / 3).floorToDouble();
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final s in statusLabels.keys)
                  _CountTile(status: s, count: counts[s] ?? 0, width: width),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              'Needs action',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Text(
              'oldest first',
              style: TextStyle(color: AppColors.muted, fontSize: 12.5),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (open.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: EmptyState(
              icon: Icons.task_alt,
              message: 'All caught up. No open reports.',
            ),
          )
        else
          for (final incident in open) ...[
            IncidentCard(
              incident: incident,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      IncidentDetailsScreen(incidentId: incident.id),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

// One pale-blue tile: how many reports have this status
class _CountTile extends StatelessWidget {
  final String status;
  final int count;
  final double width;
  const _CountTile({
    required this.status,
    required this.count,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final color = statusColors[status] ?? Colors.grey;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              color: color.shade700,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            statusLabels[status] ?? status,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
