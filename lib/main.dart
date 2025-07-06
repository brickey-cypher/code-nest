import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';            // ✅ kIsWeb defined here
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'providers/totp_provider.dart';
import 'screens/splash_router.dart';
import 'screens/sign_in_screen.dart';
import 'screens/pin_setup_screen.dart';
import 'screens/pin_lock_screen.dart';
import 'screens/totp_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔷 Explicitly set persistence on web
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

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
        '/signin': (context) => const SignInScreen(),  // ← sign-in route
        '/setup':  (context) => const PinSetupScreen(),
        '/lock':   (context) => const PinLockScreen(),
        '/totp':   (context) => const TotpListScreen(),
      },
    );
  }
}
