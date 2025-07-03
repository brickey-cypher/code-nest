import 'pin_storage_native.dart' if (dart.library.html) 'pin_storage_web.dart';

abstract class PinStorage {
  Future<void> writePin(String hashedPin);
  Future<String?> readPin();
  Future<void> clearPin();
}

PinStorage getPinStorage() => createPinStorage();
