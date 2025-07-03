import 'dart:typed_data';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../utils/base32_decoder.dart';

class TOTPGenerator {
  final List<int> secretKey;
  final int interval; // seconds, usually 30
  final int digits; // number of digits in OTP, usually 6
  final String algorithm; // 'SHA1', 'SHA256', 'SHA512'

  TOTPGenerator({
    required this.secretKey,
    this.interval = 30,
    this.digits = 6,
    this.algorithm = 'SHA1',
  });

  String generateTOTPCode({int? timestamp}) {
    // Current Unix time in seconds divided by interval (e.g., 30)
    final time =
        ((timestamp ?? DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000) ~/
        interval);

    // Convert time counter to 8-byte big endian array
    final timeBytes = _int64ToBytes(time);

    // Create HMAC digest based on selected algorithm
    final hmac = _createHmac(algorithm, secretKey, timeBytes);

    // Dynamic truncation to get a 4-byte string for the code
    final offset = hmac[hmac.length - 1] & 0xf;
    final code =
        ((hmac[offset] & 0x7f) << 24) |
        ((hmac[offset + 1] & 0xff) << 16) |
        ((hmac[offset + 2] & 0xff) << 8) |
        (hmac[offset + 3] & 0xff);

    // Modulo to get the final OTP with specified digits
    final otp = code % pow(10, digits) as int;

    // Pad with leading zeros if necessary
    return otp.toString().padLeft(digits, '0');
  }

 List<int> _int64ToBytes(int value) {
  final result = List<int>.filled(8, 0);
  var v = BigInt.from(value);

  for (int i = 7; i >= 0; i--) {
    result[i] = (v & BigInt.from(0xFF)).toInt();
    v = v >> 8;
  }

  return result;
}

  List<int> _createHmac(String algo, List<int> key, List<int> message) {
    final hmacDigest = switch (algo.toUpperCase()) {
      'SHA1' => Hmac(sha1, key).convert(message),
      'SHA256' => Hmac(sha256, key).convert(message),
      'SHA512' => Hmac(sha512, key).convert(message),
      _ => throw ArgumentError('Unsupported algorithm: $algo'),
    };
    return hmacDigest.bytes;
  }
}
