import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/totp_provider.dart';
import 'screens/splash_router.dart';
import 'screens/pin_setup_screen.dart';
import 'screens/pin_lock_screen.dart';
import 'screens/totp_list_screen.dart'; // <-- Your actual TOTP page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final provider = TotpProvider();
  await provider.loadInitialAccounts();

  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeNest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashRouter(),
      routes: {
        '/setup': (context) => const PinSetupScreen(),
        '/lock': (context) => const PinLockScreen(),
        '/totp': (context) => const TotpListScreen(), // <-- Main dashboard
      },
    );
  }
}
