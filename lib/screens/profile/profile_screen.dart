import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import 'edit_profile_screen.dart';

// The Profile tab: who is logged in, their role and numbers, and logout
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (yes != true || !context.mounted) return;
    final incidents = context.read<IncidentProvider>();
    final auth = context.read<AuthProvider>();
    incidents.stopListening(); // stop BEFORE logging out
    await auth.logout(); // AuthGate then shows the login screen by itself
  }

  void _edit(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
  );

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final p = context.watch<IncidentProvider>();
    // Students see numbers for their own reports. Staff don't send
    // reports, so they see numbers for every report on campus.
    final reports = auth.isStaff ? p.all : p.myIncidents;
    final open = reports
        .where((i) => !closedStatuses.contains(i.status))
        .length;
    final resolved = reports.where((i) => i.status == 'resolved').length;
    final name = auth.displayName;
    final hasName = name.isNotEmpty;
    // The letter in the circle: first letter of the name, else of the email
    final initial = (hasName ? name : auth.email).isEmpty
        ? '?'
        : (hasName ? name : auth.email).substring(0, 1).toUpperCase();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          // The blue header card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // No name yet? Tapping the text opens Edit profile
                GestureDetector(
                  onTap: hasName ? null : () => _edit(context),
                  child: Text(
                    hasName ? name : 'Add your name',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      decoration: hasName ? null : TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  auth.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        auth.isStaff
                            ? Icons.admin_panel_settings
                            : Icons.school,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        auth.isStaff ? 'Staff' : 'Student',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(child: _HeaderStat('${reports.length}', 'Reports')),
                    Expanded(child: _HeaderStat('$open', 'Open')),
                    Expanded(child: _HeaderStat('$resolved', 'Resolved')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Account',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.edit_outlined,
            title: 'Edit profile',
            subtitle: 'Change the name other people see',
            onTap: () => _edit(context),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.logout,
            title: 'Log out',
            subtitle: 'You can log back in any time',
            danger: true,
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}

// A number and a label in white, inside the header card
class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;
  const _HeaderStat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12.5),
        ),
      ],
    );
  }
}

// A white rounded row with an icon in a circle, used for account actions
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.primary;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.line),
    );
    return Material(
      color: AppColors.surface,
      shape: shape,
      child: ListTile(
        shape: shape,
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: danger
                ? AppColors.danger.withValues(alpha: 0.1)
                : AppColors.tint,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: danger ? AppColors.danger : AppColors.ink,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
      ),
    );
  }
}
