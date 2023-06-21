import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/digests/sha512.dart';
import 'package:pointycastle/key_derivators/api.dart' show Pbkdf2Parameters;
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';

/// PBKDF2 applies a pseudorandom function, such as hash-based message
/// authentication code (HMAC), to the input password or passphrase
/// along with a salt value and repeats the process many times to produce
/// a derived key.
class PBKDF2 {
  final int blockLength;

  /// the number of iterations desired
  final int iterationCount;

  /// the desired bit-length of the derived key
  final int desiredKeyLength;
  final String saltPrefix = "mnemonic";

  final PBKDF2KeyDerivator _derivator;

  /// PBKDF2 constructor.
  PBKDF2({
    this.blockLength = 128,
    this.iterationCount = 2048,
    this.desiredKeyLength = 64,
  }) : _derivator = PBKDF2KeyDerivator(HMac(SHA512Digest(), blockLength));

  /// This function is used to generate seed from mnemonic and passphrase.
  Uint8List process(String mnemonic, {passphrase = ""}) {
    final salt = Uint8List.fromList(utf8.encode(saltPrefix + passphrase));
    _derivator.reset();
    _derivator.init(Pbkdf2Parameters(salt, iterationCount, desiredKeyLength));
    return _derivator.process(Uint8List.fromList(utf8.encode(mnemonic)));
  }
}
