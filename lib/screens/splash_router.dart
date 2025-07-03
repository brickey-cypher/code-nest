import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'sign_in_screen.dart';
import 'pin_setup_screen.dart';
import 'pin_lock_screen.dart';

class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initRouting();
  }

  Future<void> _initRouting() async {
    final user = FirebaseAuth.instance.currentUser;

    Widget target;
    if (user == null) {
      target = const SignInScreen();
    } else {
      final pin = await _storage.read(key: 'auth_pin');
      target = pin == null ? const PinSetupScreen() : const PinLockScreen();
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => target),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

