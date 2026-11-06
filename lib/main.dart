import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/incident_provider.dart';
import 'services/auth_service.dart';
import 'services/incident_service.dart';
import 'services/storage_service.dart';
import 'screens/auth/auth_gate.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        ChangeNotifierProvider(
          create: (_) => IncidentProvider(IncidentService(), StorageService()),
        ),
      ],
      child: const CampusApp(),
    ),
  );
}

class CampusApp extends StatelessWidget {
  const CampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Reports',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(), // all colours and shapes: lib/utils/app_theme.dart
      home: const AuthGate(),
    );
  }
}
