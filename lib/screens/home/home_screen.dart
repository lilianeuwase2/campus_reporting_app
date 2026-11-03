import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.profile?.name ?? auth.email;
    final role = auth.isStaff ? 'staff' : 'student';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome, $name\nRole: $role', textAlign: TextAlign.center),
      ),
    );
  }
}
