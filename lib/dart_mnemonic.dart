library dart_mnemonic;

import 'dart:typed_data';

import 'package:hex/hex.dart';

import 'src/language.dart';
import 'src/dart_mnemonic_base.dart';

class Mnemonic {
  /// valid mnemonic words length: 12, 15, 18, 21, 24
  static const validLength = [12, 15, 18, 21, 24];

  /// entropy (strength: 128, 160, 192, 224, 256)
  late Uint8List entropy;

  /// language of the mnemonic
  ///
  /// default is english
  late Language language;

  /// passphrase of the mnemonic
  ///
  /// default is empty string
  late String passphrase;

  /// mnemonic words length: 12 15 18 21 24
  ///
  /// default is 12
  late int length;

  /// mnemonic length: 12 15 18 21 24
  ///
  /// same as [length]
  int get ms => length;

  /// checksum bits:  4  5  6  7  8
  ///
  /// It is used to get the checksum of the entropy.
  int get cs => ms ~/ 3;

  /// entropy+checksum bits
  int get entcs => ms * 11;

  /// entropy bits
  ///
  /// strength: 128, 160, 192, 224, 256
  int get ent => entcs - cs;

  /// entropy hex string
  String get entropyHex => HEX.encode(entropy);

  /// entropy binary string
  String get entropyBinary => bytesToBinary(entropy);

  /// entropy checksum binary string
  String get checksum => entropyChecksum(entropy);

  /// mnemonic words list
  List get words =>
      entropyToMnemonic(entropyBinary + checksum, language: language);

  /// mnemonic sentence string with space delimiter
  String get sentence => words.join(language.delimiter);

  /// mnemonic seed bytes
  Uint8List get seed => mnemonicToSeed(sentence, passphrase: passphrase);

  /// mnemonic seed hex string
  String get seedHex => HEX.encode(seed);

  /// This function is used to generate mnemonic.
  ///
  /// It is used to generate mnemonic from entropy.
  ///
  /// [language] is the language of the mnemonic.
  ///
  /// [passphrase] is the passphrase of the mnemonic.
  ///
  /// [length] is the words count of the mnemonic.
  Mnemonic(
      {this.language = Language.english,
      this.passphrase = '',
      this.length = 12}) {
    if (!validLength.contains(length)) {
      throw Exception('Invalid mnemonic words length');
    }
    entropy = generateEntropy(ent ~/ 8);
  }

  /// This function is used to generate mnemonic from entropy.
  ///
  /// [entropyHex] is the entropy hex string.
  ///
  /// [language] is the language of the mnemonic.
  ///
  /// [passphrase] is the passphrase of the mnemonic.
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

  /// This function is used to generate mnemonic from sentence.
  ///
  /// [sentence] is the mnemonic sentence.
  ///
  /// [passphrase] is the passphrase of the mnemonic.
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
