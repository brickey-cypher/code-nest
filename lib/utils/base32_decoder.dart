const _base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

int _charToValue(String char) {
  final index = _base32Chars.indexOf(char.toUpperCase());
  if (index == -1) {
    throw FormatException('Invalid Base32 character: $char');
  }
  return index;
}

List<int> base32Decode(String input) {
  final cleanedInput = input.replaceAll('=', '').replaceAll(' ', '');
  final bytes = <int>[];

  int buffer = 0;
  int bitsLeft = 0;

  for (final char in cleanedInput.split('')) {
    buffer <<= 5;
    buffer |= _charToValue(char) & 0x1F;
    bitsLeft += 5;

    if (bitsLeft >= 8) {
      bitsLeft -= 8;
      final byte = (buffer >> bitsLeft) & 0xFF;
      bytes.add(byte);
    }
  }
  return bytes;
}
