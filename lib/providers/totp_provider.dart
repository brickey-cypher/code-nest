import 'dart:async';
import 'package:flutter/material.dart';
import '../models/totp_account.dart';
import '../logic/totp_generator.dart';
import '../utils/base32_decoder.dart';
import '../services/secure_storage_service.dart';

class TotpProvider extends ChangeNotifier {
  final List<TotpAccount> _accounts = [];
  final Map<String, String> _currentCodes = {};
  final Map<String, TOTPGenerator> _generators = {};

  final SecureStorageService _storageService = SecureStorageService();

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
    await _storageService.clearAllAccounts();
    notifyListeners();
  }

  Future<void> _loadAccounts() async {
    try {
      final savedAccounts = await _storageService.loadAccounts();
      _accounts.addAll(savedAccounts);

      for (var account in savedAccounts) {
        final decodedKey = base32Decode(account.secret);
        _generators[account.secret] = TOTPGenerator(secretKey: decodedKey);
        _updateCodeFor(account);
      }
    } catch (e) {
      // handle error gracefully
    }
    notifyListeners();
  }

  void addAccount(TotpAccount account) {
    if (_accounts.any((a) =>
        a.issuer == account.issuer && a.accountName == account.accountName)) {
      return;
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
    await _storageService.saveAccounts(_accounts);
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
