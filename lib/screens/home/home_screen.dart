import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../incidents/new_incident_screen.dart';
import 'report_list_slivers.dart';

// The Home tab: the banner, a small report summary and the latest reports.
// Searching and filtering live on the Search tab.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isStaff = context.watch<AuthProvider>().isStaff;
    final p = context.watch<IncidentProvider>();
    final reports = p.all; // every report, newest first
    final ready = !p.isLoading && p.loadError == null;
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Reports')),
      // A CustomScrollView lets the top part and the list scroll together
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Banner(
                    isStaff: isStaff,
                    // Only students report problems, so staff get no button
                    onReport: isStaff
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NewIncidentScreen(),
                            ),
                          ),
                  ),
                  if (ready) ...[
                    const SizedBox(height: 24),
                    _SectionTitle(
                      title: 'Report summary',
                      trailing: isStaff ? 'All reports' : 'Your reports',
                    ),
                    const SizedBox(height: 10),
                    // Students see their own numbers; staff see the campus
                    _ReportSummary(
                      reports: isStaff ? reports : p.myIncidents,
                    ),
                  ],
                  const SizedBox(height: 24),
                  _SectionTitle(
                    title: 'Recent reports',
                    trailing: ready
                        ? '${reports.length} '
                              '${reports.length == 1 ? 'report' : 'reports'}'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          ...reportListSlivers(
            context,
            provider: p,
            items: reports,
            emptyMessage: isStaff
                ? 'No reports yet.'
                : 'No reports yet. Tap + to report a problem.',
          ),
        ],
      ),
    );
  }
}

// A heading with small grey text on the right, e.g. "Recent reports   4 reports"
class _SectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;
  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
          ),
      ],
    );
  }
}

// The navy box at the top. Students are invited to report a problem;
// staff see what their job is instead, with no report button.
class _Banner extends StatelessWidget {
  final bool isStaff;
  final VoidCallback? onReport; // null means: no button
  const _Banner({required this.isStaff, this.onReport});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias, // cut the big faded icon at the corners
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: Stack(
        children: [
          // A large faded icon in the corner, just for decoration
          Positioned(
            right: -18,
            bottom: -24,
            child: Icon(
              isStaff ? Icons.fact_check_rounded : Icons.campaign_rounded,
              size: 130,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isStaff ? 'STAFF VIEW' : 'SEE IT · REPORT IT',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isStaff
                      ? 'Reports from students'
                      : 'Seen a problem on campus?',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isStaff
                      ? 'Open a report to update its status and leave a '
                            'note for the student.'
                      : 'Report it in a minute and follow it until it is '
                            'fixed.',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                if (onReport != null) ...[
                  const SizedBox(height: 16),
                  // A white pill button with an arrow
                  FilledButton(
                    onPressed: onReport,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(0, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Report now'),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Four small boxes with counts, like the "Report Summary" in the sample.
// "In progress" also counts reports that are "In review", because staff
// are already working on both. Rejected reports are only in the total.
class _ReportSummary extends StatelessWidget {
  final List<Incident> reports;
  const _ReportSummary({required this.reports});

  // How many of the reports have one of these statuses
  int _count(List<String> statuses) =>
      reports.where((i) => statuses.contains(i.status)).length;

  // The same colour as that status's badge, a little darker
  Color _colorOf(String status) =>
      (statusColors[status] ?? Colors.grey).shade700;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryTile(
          count: reports.length,
          label: 'Total',
          color: AppColors.primary,
        ),
        const SizedBox(width: 10),
        _SummaryTile(
          count: _count(['submitted']),
          label: 'Submitted',
          color: _colorOf('submitted'),
        ),
        const SizedBox(width: 10),
        _SummaryTile(
          count: _count(['in_review', 'in_progress']),
          label: 'In progress',
          color: _colorOf('in_progress'),
        ),
        const SizedBox(width: 10),
        _SummaryTile(
          count: _count(['resolved']),
          label: 'Resolved',
          color: _colorOf('resolved'),
        ),
      ],
    );
  }
}

// One white box in the summary: a big number with a small label under it
class _SummaryTile extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _SummaryTile({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Expanded makes the four boxes share the row equally
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontFamily: 'serif',
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }
}
