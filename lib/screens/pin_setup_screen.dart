import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  String? _errorMessage;
  bool _isSaving = false;

  Future<void> _savePin(String pin) async {
    final bytes = utf8.encode(pin);
    final hashedPin = sha256.convert(bytes).toString();

    await _storage.write(key: 'auth_pin', value: hashedPin);
  }

  void _onSubmit() async {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmController.text.trim();

   if (pin.length < 4 || pin.length > 6) {
  setState(() {
    _errorMessage = 'PIN must be between 4 and 6 digits.';
  });
  return;
}

    if (pin != confirmPin) {
      setState(() {
        _errorMessage = 'PINs do not match.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    await _savePin(pin);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/totp'); // Adjust route if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Your PIN')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Create a 4-digit PIN to secure your TOTP codes.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'Enter PIN'),
               onSubmitted: (_) => _onSubmit(),
            ),
            TextField(
              controller: _confirmController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'Confirm PIN'),
              onSubmitted: (_) => _onSubmit(),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSaving ? null : _onSubmit,
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : const Text('Save PIN'),
            ),
          ],
        ),
      ),
    );
  }
}
