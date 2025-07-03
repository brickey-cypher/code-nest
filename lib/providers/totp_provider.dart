import 'dart:async';
import 'package:flutter/material.dart';
import '../models/totp_account.dart';
import '../logic/totp_generator.dart';
import '../utils/base32_decoder.dart';
import '../services/pin_storage.dart';  // <- change here: use pin_storage abstraction

class TotpProvider extends ChangeNotifier {
  final List<TotpAccount> _accounts = [];
  final Map<String, String> _currentCodes = {};
  final Map<String, TOTPGenerator> _generators = {};

  // Use the platform-aware PinStorage instance instead of SecureStorageService
  final PinStorage _storageService = getPinStorage();

  Timer? _timer;
  int _secondsRemaining = 30;

  TotpProvider() {
    _loadAccounts();
    _startTimer();
  }

  List<TotpAccount> get accounts => List.unmodifiable(_accounts);
  Map<String, String> get currentCodes => Map.unmodifiable(_currentCodes);
  int get secondsRemaining => _secondsRemaining;

  Future<void> loadInitialAccounts() async {
    await _loadAccounts();
  }

  Future<void> clearAllAccounts() async {
    _accounts.clear();
    // Clear persistent storage here if applicable.
    await _storageService.clearPin();  // clear the stored pin and data if needed

    notifyListeners();
  }

  Future<void> _loadAccounts() async {
    try {
      final savedJson = await _storageService.readPin();
      if (savedJson != null) {
        // Assuming you store accounts as JSON string in the same pin storage
        final savedAccounts = TotpAccount.listFromJson(savedJson);
        _accounts.addAll(savedAccounts);

        for (var account in savedAccounts) {
          final decodedKey = base32Decode(account.secret);
          _generators[account.secret] = TOTPGenerator(secretKey: decodedKey);
          _updateCodeFor(account);
        }
      }
    } catch (e) {
      // handle error or no stored accounts gracefully
    }
    notifyListeners();
  }

  void addAccount(TotpAccount account) {
    if (_accounts.any((a) =>
        a.issuer == account.issuer && a.accountName == account.accountName)) {
      return; // prevent duplicates
    }

    _accounts.add(account);

    final decodedKey = base32Decode(account.secret);
    _generators[account.secret] = TOTPGenerator(secretKey: decodedKey);

    _updateCodeFor(account);
    _saveAccounts();
    notifyListeners();
  }

  void removeAccount(TotpAccount account) {
    _accounts.remove(account);
    _generators.remove(account.secret);
    _currentCodes.remove(account.secret);
    _saveAccounts();
    notifyListeners();
  }

  Future<void> _saveAccounts() async {
    // Serialize accounts list as JSON string
    final jsonString = TotpAccount.listToJson(_accounts);
    await _storageService.writePin(jsonString);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final currentUnixTime = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
      _secondsRemaining = 30 - (currentUnixTime % 30);

      for (var account in _accounts) {
        _updateCodeFor(account);
      }
      notifyListeners();
    });
  }

  void _updateCodeFor(TotpAccount account) {
    final generator = _generators[account.secret];
    if (generator != null) {
      final code = generator.generateTOTPCode();
      _currentCodes[account.secret] = code;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
