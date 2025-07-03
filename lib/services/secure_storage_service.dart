// lib/services/secure_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/totp_account.dart';
import 'dart:convert';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();
  final String _storageKey = 'totp_accounts';

  /// Save the list of TOTP accounts securely
  Future<void> saveAccounts(List<TotpAccount> accounts) async {
    final accountMaps = accounts.map((a) => {
          'issuer': a.issuer,
          'accountName': a.accountName,
          'secret': a.secret,
        }).toList();

    final jsonString = jsonEncode(accountMaps);
    await _storage.write(key: _storageKey, value: jsonString);
  }

  /// Load TOTP accounts from secure storage
  Future<List<TotpAccount>> loadAccounts() async {
    final jsonString = await _storage.read(key: _storageKey);
    if (jsonString == null) return [];

    final List<dynamic> accountMaps = jsonDecode(jsonString);
    return accountMaps
        .map((map) => TotpAccount(
              issuer: map['issuer'],
              accountName: map['accountName'],
              secret: map['secret'],
            ))
        .toList();
  }

Future<void> clearAllAccounts() async {
  await _storage.delete(key: _storageKey); // _storageKey should match your account storage key
}
}

