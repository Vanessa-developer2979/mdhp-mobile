
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';

import 'core/colors.dart';
import 'core/router.dart';

import 'services/auth_service.dart';
import 'services/record_service.dart';
import 'services/qr_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize the patient authentication service.
  final authService = AuthService();

  // Initialize the patient navigation router.
  final GoRouter appRouter = createRouter(authService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(
          value: authService,
        ),

        ChangeNotifierProvider<RecordService>(
          create: (_) => RecordService(),
        ),

        ChangeNotifierProvider<QrService>(
          create: (_) => QrService(),
        ),
      ],
      child: PatientApp(
        router: appRouter,
      ),
    ),
  );
}

class PatientApp extends StatelessWidget {
  final GoRouter router;

  const PatientApp({
    super.key,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Malawi Digital Health Passport',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),
      ),
      routerConfig: router,
    );
  }
}
