import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'pin_storage.dart';

class NativePinStorage implements PinStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _key = 'auth_pin';

  @override
  Future<void> writePin(String hashedPin) async {
    await _storage.write(key: _key, value: hashedPin);
  }

  @override
  Future<String?> readPin() async {
    return await _storage.read(key: _key);
  }

  @override
  Future<void> clearPin() async {
    await _storage.delete(key: _key);
  }
}

PinStorage createPinStorage() => NativePinStorage();
