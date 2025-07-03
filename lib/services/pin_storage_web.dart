//ignore_for_file: avoid_web_libraries_in_flutter
// ignore: deprecated_member_use
import 'dart:html' as html;

import 'pin_storage.dart';

class WebPinStorage implements PinStorage {
  final String _key = 'auth_pin';

  @override
  Future<void> writePin(String hashedPin) async {
    html.window.localStorage[_key] = hashedPin;
  }

  @override
  Future<String?> readPin() async {
    return html.window.localStorage[_key];
  }

  @override
  Future<void> clearPin() async {
    html.window.localStorage.remove(_key);
  }
}

PinStorage createPinStorage() => WebPinStorage();
