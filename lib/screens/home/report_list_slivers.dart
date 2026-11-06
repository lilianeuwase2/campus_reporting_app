import 'package:flutter/material.dart';

import '../../models/incident.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_card.dart';
import '../incidents/incident_details_screen.dart';

// The list part of the Home and Search tabs: a spinner while loading, an
// error with "Try again", a message when there is nothing, or the cards.
// Shared so both tabs look and behave the same without repeating code.
List<Widget> reportListSlivers(
  BuildContext context, {
  required IncidentProvider provider,
  required List<Incident> items,
  required String emptyMessage,
  IconData emptyIcon = Icons.inbox_outlined,
}) {
  if (provider.isLoading) {
    return const [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    ];
  }
  if (provider.loadError != null) {
    return [
      SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          icon: Icons.cloud_off,
          message: provider.loadError!,
          actionLabel: 'Try again',
          onAction: provider.retry,
        ),
      ),
    ];
  }
  if (items.isEmpty) {
    return [
      SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(icon: emptyIcon, message: emptyMessage),
      ),
    ];
  }
  return [
    SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      sliver: SliverList.separated(
        itemCount: items.length,
        itemBuilder: (context, index) => IncidentCard(
          incident: items[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  IncidentDetailsScreen(incidentId: items[index].id),
            ),
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
      ),
    ),
  ];
}
