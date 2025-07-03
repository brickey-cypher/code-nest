import 'dart:convert';

class TotpAccount {
  final String issuer;
  final String accountName;
  final String secret;

  TotpAccount({
    required this.issuer,
    required this.accountName,
    required this.secret,
  });

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'issuer': issuer,
      'accountName': accountName,
      'secret': secret,
    };
  }

  // Convert JSON back to object
  factory TotpAccount.fromJson(Map<String, dynamic> json) {
    return TotpAccount(
      issuer: json['issuer'],
      accountName: json['accountName'],
      secret: json['secret'],
    );
  }

  @override
  String toString() => 'TotpAccount(issuer: $issuer, accountName: $accountName)';

  // NEW: List conversion helpers
  static List<TotpAccount> listFromJson(String jsonString) {
    final data = json.decode(jsonString) as List<dynamic>;
    return data.map((e) => TotpAccount.fromJson(e)).toList();
  }

  static String listToJson(List<TotpAccount> accounts) {
    final data = accounts.map((e) => e.toJson()).toList();
    return json.encode(data);
  }
}
