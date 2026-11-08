import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'services/auth_service.dart';
import 'services/record_service.dart';
import 'services/qr_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MdhpMobileApp());
}

class MdhpMobileApp extends StatefulWidget {
  const MdhpMobileApp({super.key});

  @override
  State<MdhpMobileApp> createState() => _MdhpMobileAppState();
}

class _MdhpMobileAppState extends State<MdhpMobileApp> {
  late final AuthService _authService;
  late final RecordService _recordService;
  late final QrService _qrService;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _authService = AuthService();
    _recordService = RecordService();
    _qrService = QrService();

    // Create the router once.
    _router = createRouter(_authService);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authService),
        ChangeNotifierProvider.value(value: _recordService),
        ChangeNotifierProvider.value(value: _qrService),
      ],
      child: MaterialApp.router(
        title: 'Malawi Digital Health Passport',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _authService.dispose();
    _recordService.dispose();
    _qrService.dispose();

    super.dispose();
  }
}
