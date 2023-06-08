import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:hex/hex.dart';
import 'package:unorm_dart/unorm_dart.dart';

import 'language.dart';
import 'pbkdf2.dart';

/// This function is used to convert bytes to binary.
/// It is used to convert entropy bytes to binary and
/// to convert the sha256 hash of the entropy to binary.
String bytesToBinary(Uint8List bytes) {
  return bytes.map((byte) => byte.toRadixString(2).padLeft(8, '0')).join('');
}

/// This function is used to  hex string to bytes.
/// It is used to convert entropy hex string to bytes.
Uint8List hexToBytes(String hex) {
  return Uint8List.fromList(HEX.decode(hex));
}

/// This function is used to convert binary to int.
/// It is used to convert the sha256 hash of the entropy to int.
int binaryToInt(String binary) {
  return int.parse(binary, radix: 2);
}

/// This function is used to generate entropy.
/// It is used to generate entropy for the mnemonic.
Uint8List generateEntropy(int strength) {
  final rng = Random.secure();
  final bytes = Uint8List(strength);
  for (var i = 0; i < strength; i++) {
    bytes[i] = rng.nextInt(256);
  }
  return bytes;
}

/// This function is used to get entropy checksum
/// It is used to get the checksum of the entropy.
String entropyChecksum(Uint8List entropy) {
  final entropyLength = entropy.length * 8;
  final checksumLength = entropyLength ~/ 32;
  final hash = sha256.convert(entropy);
  return bytesToBinary(Uint8List.fromList(hash.bytes))
      .substring(0, checksumLength);
}

/// This function is used to generate mnemonic from entropy and checksum.
List entropyToMnemonic(String entropyAndChecksum,
    {language = Language.english}) {
  final regex = RegExp(r".{1,11}", caseSensitive: false, multiLine: false);
  final chunks =
      regex.allMatches(entropyAndChecksum).map((m) => m.group(0)).toList();
  final list = language.wordlist;
  final mnomonic = chunks.map((binary) => list[binaryToInt(binary!)]).toList();
  return mnomonic;
}

/// This function is used to compute entropy from mnemonic.
Uint8List mnemonicToEntropy(List<String> mnemonic, Language language) {
  mnemonic = mnemonic.map((word) => nfkd(word)).toList();
  final list = language.wordlist;
  final bits = mnemonic.map((word) {
    final index = list.indexOf(word);
    if (index == -1) {
      throw Exception('Invalid mnemonic word');
    }
    return index.toRadixString(2).padLeft(11, '0');
  }).join('');
  final entropyBits = bits.substring(0, bits.length - bits.length ~/ 33);

  final regex = RegExp(r".{1,8}", caseSensitive: false, multiLine: false);
  final chunks = regex.allMatches(entropyBits).map((m) => m.group(0)).toList();
  final entropy = chunks.map((binary) => binaryToInt(binary!)).toList();
  return Uint8List.fromList(entropy);
}

/// This function is used to generate seed from mnemonic sentence.
Uint8List mnemonicToSeed(String sentence, {String passphrase = ''}) {
  sentence = nfkd(sentence);
  final pbkdf2 = PBKDF2();
  return pbkdf2.process(sentence, passphrase: passphrase);
}

/// This function is used to check mnemonic list language.
/// If the mnemonic list is not in any language, it will return unknown.
/// If the mnemonic list is in more than one language, it will return unknown.
Language mnemonicLanguage(List<String> mnemonic) {
  for (final l in Language.values) {
    final list = l.wordlist;
    var matched = 0;
    for (final m in mnemonic) {
      if (!list.contains(m)) {
        break;
      }
      matched++;
    }
    if (matched == mnemonic.length) {
      return l;
    }
  }
  return Language.unknown;
}
