library dart_mnemonic;

import 'dart:typed_data';

import 'package:hex/hex.dart';

import 'src/language.dart';
import 'src/dart_mnemonic_base.dart';

class Mnemonic {
  // valid mnemonic words length
  static const validLength = [12, 15, 18, 21, 24];

  late Uint8List entropy;

  late Language language;
  late String passphrase;
  // mnemonic length: 12 15 18 21 24
  late int length;

  // mnemonic length: 12 15 18 21 24
  int get ms => length;
  // checksum bits:  4  5  6  7  8
  int get cs => ms ~/ 3;
  // entropy+checksum bits
  int get entcs => ms * 11;
  // entropy bits
  int get ent => entcs - cs;

  // entropy hex string
  String get entropyHex => HEX.encode(entropy);
  // entropy binary string
  String get entropyBinary => bytesToBinary(entropy);

  // entropy checksum
  String get checksum => entropyChecksum(entropy);

  // mnemonic words
  List get words =>
      entropyToMnemonic(entropyBinary + checksum, language: language);
  // mnemonic sentence
  String get sentence => words.join(language.delimiter);

  // mnemonic seed
  Uint8List get seed => mnemonicToSeed(sentence, passphrase: passphrase);
  // mnemonic seed hex string
  String get seedHex => HEX.encode(seed);

  // Construct mnemonic
  Mnemonic(
      {this.language = Language.english,
      this.passphrase = '',
      this.length = 12}) {
    if (!validLength.contains(length)) {
      throw Exception('Invalid mnemonic words length');
    }
    entropy = generateEntropy(ent ~/ 8);
  }

  // Construct mnemonic from entropy hex string
  Mnemonic.fromEntropy(String entropyHex,
      {this.language = Language.english, this.passphrase = ''}) {
    // check entropy hex string is valid hex string
    if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(entropyHex)) {
      throw Exception('Invalid entropy hex string');
    }

    // check entropy hex string length
    final hexENT = entropyHex.length * 4;
    final hexCS = hexENT ~/ 32;
    final hexMS = hexCS * 3;
    if (!validLength.contains(hexMS) || hexENT % 32 != 0) {
      throw Exception('Invalid entropy hex length');
    }
    length = hexMS;
    entropy = hexToBytes(entropyHex);
  }

  // Construct mnemonic from mnemonic words in sentence
  Mnemonic.fromMnemonic(String sentence, {this.passphrase = ''}) {
    sentence = sentence.replaceAll(RegExp(r'[\s+,，]'), ' ');
    sentence = sentence.trim();
    sentence = sentence.toLowerCase();
    final words = sentence.split(RegExp(r'\s+'));
    if (!validLength.contains(words.length)) {
      throw Exception('Invalid mnemonic words length');
    }
    length = words.length;

    language = mnemonicLanguage(words);
    if (language.name == 'unknown') {
      throw Exception('Invalid mnemonic words with unknown language');
    }
    entropy = mnemonicToEntropy(words, language);
  }
}
