import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// One-time values that bind an Apple identity token to this sign-in attempt
/// (replay protection).
final class NonceGenerator {
  NonceGenerator({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  /// URL-safe random string from [byteLength] secure random bytes.
  String generate({int byteLength = 32}) {
    final bytes = List<int>.generate(byteLength, (_) => _random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  /// Lower-case hex SHA-256, the form Apple embeds in the token's `nonce`.
  String sha256Hex(String raw) => sha256.convert(utf8.encode(raw)).toString();
}
