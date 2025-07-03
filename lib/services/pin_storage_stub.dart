// lib/services/pin_storage_stub.dart

import 'pin_storage.dart';

class UnsupportedPinStorage implements PinStorage {
  @override
  Future<void> writePin(String hashedPin) async {
    throw UnsupportedError('PIN storage not supported on this platform');
  }

  @override
  Future<String?> readPin() async {
    throw UnsupportedError('PIN storage not supported on this platform');
  }

  @override
  Future<void> clearPin() async {
    throw UnsupportedError('PIN storage not supported on this platform');
  }
}

PinStorage getPinStorage() => UnsupportedPinStorage();
