import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/incident.dart';
import '../../models/status_update.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/staff_status_panel.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/status_timeline.dart';

class IncidentDetailsScreen extends StatefulWidget {
  final String incidentId;
  const IncidentDetailsScreen({super.key, required this.incidentId});

  @override
  State<IncidentDetailsScreen> createState() => _IncidentDetailsScreenState();
}

class _IncidentDetailsScreenState extends State<IncidentDetailsScreen> {
  late final Stream<Incident?> _stream;
  late final Stream<List<StatusUpdate>> _updates;

  @override
  void initState() {
    super.initState();
    // Create the streams ONCE here. If they were created in build(),
    // every rebuild would open a new connection to Firestore.
    final provider = context.read<IncidentProvider>();
    _stream = provider.watchIncident(widget.incidentId);
    _updates = provider.watchUpdates(widget.incidentId);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return StreamBuilder<Incident?>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _page(
            const EmptyState(
              icon: Icons.cloud_off,
              message: 'Could not load this report.',
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _page(const Center(child: CircularProgressIndicator()));
        }
        final incident = snapshot.data;
        if (incident == null) {
          return _page(
            const EmptyState(
              icon: Icons.delete_outline,
              message: 'This report no longer exists.',
            ),
          );
        }
        // Only the reporter can delete, and only before staff act on it
        final canDelete =
            incident.reporterId == auth.uid && incident.status == 'submitted';
        return _page(
          _details(incident, isStaff: auth.isStaff),
          actions: [
            if (canDelete)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete report',
                onPressed: () => _confirmDelete(incident),
              ),
          ],
        );
      },
    );
  }

  Widget _page(Widget body, {List<Widget> actions = const []}) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report details'), actions: actions),
      body: body,
    );
  }

  Widget _details(Incident incident, {required bool isStaff}) {
    final date = incident.createdAt == null
        ? 'Just now'
        : DateFormat('d MMM yyyy, HH:mm').format(incident.createdAt!);
    // A scrolling Column (not a ListView) so the history and the staff panel
    // keep their state when the staff-note card appears above them
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(incident, date),
          if (incident.photoUrl != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                incident.photoUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const SizedBox(
                        height: 220,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                errorBuilder: (context, error, stack) => Container(
                  height: 120,
                  color: AppColors.tint,
                  alignment: Alignment.center,
                  child: const Text(
                    'Photo not available right now',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _Section(
            title: 'Description',
            child: Text(
              incident.description,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
          if (incident.staffNote != null && incident.staffNote!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.tint,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Latest note from staff',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          incident.staffNote!,
                          style: const TextStyle(color: AppColors.ink),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          _Section(
            key: const ValueKey('progress'),
            title: 'Progress',
            // The history updates live, like the report itself
            child: StreamBuilder<List<StatusUpdate>>(
              stream: _updates,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Could not load the progress history.');
                }
                return StatusTimeline(
                  submittedAt: incident.createdAt,
                  updates: snapshot.data ?? const [],
                );
              },
            ),
          ),
          // Students never see this panel. The Firestore rules also block
          // status changes from non-staff, in case someone bypasses the app.
          if (isStaff) ...[
            const SizedBox(height: 16),
            StaffStatusPanel(
              key: const ValueKey('staff-panel'),
              incident: incident,
            ),
          ],
        ],
      ),
    );
  }

  // The blue card at the top: category, status, title, place, reporter, date
  Widget _header(Incident incident, String date) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  categoryIcons[incident.category] ?? Icons.help_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  categoryLabels[incident.category] ?? incident.category,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              StatusChip(status: incident.status, onDark: true),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            incident.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _InfoRow(icon: Icons.place_outlined, text: incident.location),
          _InfoRow(
            icon: Icons.person_outline,
            text: 'Reported by ${incident.reporterName}',
          ),
          _InfoRow(icon: Icons.schedule, text: date),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Incident incident) async {
    // showDialog waits until the user taps a button, then returns true or false
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this report?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;

    // Grab these BEFORE the next await, while the screen still exists
    final provider = context.read<IncidentProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final error = await provider.deleteIncident(incident);
    if (error == null) navigator.pop(); // back to the list
    messenger.showSnackBar(SnackBar(content: Text(error ?? 'Report deleted')));
  }
}

// A white rounded box with a small title, used for each part of the report
class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// A small white icon + text line inside the blue header
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 17, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
