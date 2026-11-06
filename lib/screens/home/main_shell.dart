import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/app_theme.dart';
import '../incidents/my_reports_screen.dart';
import '../incidents/new_incident_screen.dart';
import '../profile/profile_screen.dart';
import '../staff/staff_dashboard_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';

// One tab in the bottom bar
class _Tab {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
  const _Tab(this.label, this.icon, this.selectedIcon, this.page);
}

// The frame around the main screens, with a rounded navy bottom bar.
//   Students: Home · Search · ( + ) · My reports · Profile
//   Staff:    Home · Search · Staff · Profile
// Only students report problems, so staff have no + button.
// The bigger + in the middle opens the new-report form.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0; // which tab is open: local UI state, so setState is fine
  late final IncidentProvider _incidents;

  @override
  void initState() {
    super.initState();
    // Start listening to reports ONCE here, so every tab shares the same data
    _incidents = context.read<IncidentProvider>();
    _incidents.startListening(context.read<AuthProvider>().uid!);
  }

  @override
  void dispose() {
    // The shell disappears when the user logs out: stop and clear the data
    _incidents.stopListening();
    super.dispose();
  }

  void _newReport() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const NewIncidentScreen()),
  );

  @override
  Widget build(BuildContext context) {
    final isStaff = context.watch<AuthProvider>().isStaff;
    // Both roles have 4 tabs. The third one is "Staff" for staff
    // and "My reports" for students.
    final tabs = [
      const _Tab('Home', Icons.home_outlined, Icons.home_rounded, HomeScreen()),
      const _Tab(
        'Search',
        Icons.search_outlined,
        Icons.search_rounded,
        SearchScreen(),
      ),
      if (isStaff)
        const _Tab(
          'Staff',
          Icons.dashboard_outlined,
          Icons.dashboard_rounded,
          StaffDashboardScreen(),
        )
      else
        const _Tab(
          'My reports',
          Icons.assignment_outlined,
          Icons.assignment_rounded,
          MyReportsScreen(),
        ),
      const _Tab(
        'Profile',
        Icons.person_outline,
        Icons.person_rounded,
        ProfileScreen(),
      ),
    ];

    Widget item(int i) => Expanded(
      child: _NavItem(
        tab: tabs[i],
        selected: i == _tab,
        onTap: () => setState(() => _tab = i),
      ),
    );

    return Scaffold(
      // IndexedStack keeps every tab alive, so the search text and
      // scroll position are still there when you come back to a tab
      body: IndexedStack(
        index: _tab,
        children: [for (final tab in tabs) tab.page],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            height: 66,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(26),
              boxShadow: AppColors.softShadow,
            ),
            // A see-through Material so the tap ripple shows on the navy bar
            child: Material(
              type: MaterialType.transparency,
              child: Row(
                children: [
                  item(0),
                  item(1),
                  // Students get the + in the middle, two tabs on each side.
                  // Staff just get their 4 tabs spread evenly.
                  if (!isStaff) Expanded(child: _AddButton(onTap: _newReport)),
                  item(2),
                  item(3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// One tab button in the navy bar: white when selected, faded when not
class _NavItem extends StatelessWidget {
  final _Tab tab;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : Colors.white60;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // A soft pill behind the selected icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white.withValues(alpha: 0.16)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              selected ? tab.selectedIcon : tab.icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            tab.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// The bigger round + in the middle of the bar (students only). It sits
// slightly above the bar, with a light ring around it, so it stands out.
class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -12),
        child: Tooltip(
          message: 'New report',
          child: Material(
            color: AppColors.surface,
            elevation: 4,
            shadowColor: Colors.black26,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.background, width: 4),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: const SizedBox(
                width: 60,
                height: 60,
                child: Icon(
                  Icons.add_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
