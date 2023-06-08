import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:hex/hex.dart';
import 'package:unorm_dart/unorm_dart.dart';

import 'language.dart';
import 'pbkdf2.dart';

// convert bytes to binary
String bytesToBinary(Uint8List bytes) {
  return bytes.map((byte) => byte.toRadixString(2).padLeft(8, '0')).join('');
}

// hex string to bytes
Uint8List hexToBytes(String hex) {
  return Uint8List.fromList(HEX.decode(hex));
}

// convert binary to int
int binaryToInt(String binary) {
  return int.parse(binary, radix: 2);
}

// generate entropy
Uint8List generateEntropy(int strength) {
  final rng = Random.secure();
  final bytes = Uint8List(strength);
  for (var i = 0; i < strength; i++) {
    bytes[i] = rng.nextInt(256);
  }
  return bytes;
}

// entropy checksum
String entropyChecksum(Uint8List entropy) {
  final entropyLength = entropy.length * 8;
  final checksumLength = entropyLength ~/ 32;
  final hash = sha256.convert(entropy);
  return bytesToBinary(Uint8List.fromList(hash.bytes))
      .substring(0, checksumLength);
}

// entropy to mnemonic
List entropyToMnemonic(String entropyAndChecksum,
    {language = Language.english}) {
  final regex = RegExp(r".{1,11}", caseSensitive: false, multiLine: false);
  final chunks =
      regex.allMatches(entropyAndChecksum).map((m) => m.group(0)).toList();
  final list = language.wordlist;
  final mnomonic = chunks.map((binary) => list[binaryToInt(binary!)]).toList();
  return mnomonic;
}

// mnemonic to entropy
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

// mnemonic sentence to seed
Uint8List mnemonicToSeed(String sentence, {String passphrase = ''}) {
  sentence = nfkd(sentence);
  final pbkdf2 = PBKDF2();
  return pbkdf2.process(sentence, passphrase: passphrase);
}

// check mnemonic language
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
