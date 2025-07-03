import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:provider/provider.dart';

import '../providers/totp_provider.dart';
import '../services/pin_storage.dart'; // ✅ our abstraction

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final TextEditingController _pinController = TextEditingController();
  final PinStorage _pinStorage = getPinStorage(); // ✅ use abstraction

  String? _errorMessage;
  bool _isChecking = false;

  Future<bool> _validatePin(String inputPin) async {
    final savedHash = await _pinStorage.readPin();
    if (savedHash == null) return false;

    final inputHash = sha256.convert(utf8.encode(inputPin)).toString();
    return inputHash == savedHash;
  }

  void _onSubmit() async {
    final input = _pinController.text.trim();

    if (input.length < 4 || input.length > 6) {
      setState(() {
        _errorMessage = 'PIN must be between 4 and 6 digits.';
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    final isValid = await _validatePin(input);

    setState(() {
      _isChecking = false;
    });

    if (isValid) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/totp');
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN. Try again.';
      });
    }
  }

  void _resetPin() async {
    final provider = Provider.of<TotpProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset PIN and Erase Data?'),
        content: const Text(
          'Resetting your PIN will erase all saved TOTP accounts. '
          'This action cannot be undone. Do you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _pinStorage.clearPin();          // ✅ clears PIN
      await provider.clearAllAccounts();     // ✅ clears accounts

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter PIN')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your PIN to access the authenticator.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'PIN'),
              onSubmitted: (_) => _onSubmit(),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isChecking ? null : _onSubmit,
              child: _isChecking
                  ? const CircularProgressIndicator()
                  : const Text('Unlock'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _resetPin,
              child: const Text(
                'Reset PIN (erase all data)',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
