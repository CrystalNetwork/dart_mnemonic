import 'dart:convert';
import 'dart:io';

import 'package:dart_mnemonic/src/language.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dart_mnemonic/dart_mnemonic.dart';

final vectors =
    json.decode(File('./test/vectors.json').readAsStringSync(encoding: utf8));

void main() {
  test('example', () {
    // Generate a random mnemonic
    var mnemonic = Mnemonic();
    debugPrint("entropy: ${mnemonic.entropyHex}");
    debugPrint("words: ${mnemonic.words}");
    debugPrint("sentence: ${mnemonic.sentence}");
    debugPrint("seed: ${mnemonic.seedHex}");

    // Generate a mnemonic from a known entropy
    var m2 = Mnemonic.fromEntropy("141f7c6da5d76d453497a9f9b3bc44ca");
    debugPrint("entropy: ${m2.entropyHex}");
    // => entropy: 141f7c6da5d76d453497a9f9b3bc44ca
    debugPrint("words: ${m2.words}");
    // => words: [beef, winner, bread, entry, item, penalty, spoil, vivid, whale, over, bachelor, net]
    debugPrint("sentence: ${m2.sentence}");
    // => beef winner bread entry item penalty spoil vivid whale over bachelor net
    debugPrint("seed: ${m2.seedHex}");
    // => seed: cc9441bf020f9b45ad920404ee8a40139dc8cf1eca9ee5720743c4ae2a085c391fede2e19cd4fe345f12767ee8829f3cfb5d2e041ddbbc14d072e568ac506e69

    // Generate a mnemonic from a known mnemonic sentence
    var m3 = Mnemonic.fromMnemonic(
        "beef winner bread entry item penalty spoil vivid whale over bachelor net");
    debugPrint("entropy: ${m3.entropyHex}");
    // => entropy: 141f7c6da5d76d453497a9f9b3bc44ca
    debugPrint("words: ${m3.words}");
    // => words: [beef, winner, bread, entry, item, penalty, spoil, vivid, whale, over, bachelor, net]
    debugPrint("sentence: ${m3.sentence}");
    // => beef winner bread entry item penalty spoil vivid whale over bachelor net
    debugPrint("seed: ${m3.seedHex}");
    // => seed: cc9441bf020f9b45ad920404ee8a40139dc8cf1eca9ee5720743c4ae2a085c391fede2e19cd4fe345f12767ee8829f3cfb5d2e041ddbbc14d072e568ac506e69

    // Generate a mnemonic in Japanese with a passphrase and a word count of 24
    var m4 = Mnemonic(
        language: Language.japanese, passphrase: "passphrase", length: 24);
    debugPrint("entropy: ${m4.entropyHex}");
    debugPrint("words: ${m4.words}");
    debugPrint("sentence: ${m4.sentence}");
    debugPrint("seed: ${m4.seedHex}");
  });

  test('mnemonic initialize', () {
    const language = Language.japanese;
    final mnemonic = Mnemonic(language: language, passphrase: "", length: 24);
    debugPrint("entropy: ${mnemonic.entropy.toString()}");
    debugPrint(
        "entropyHex: ${mnemonic.entropyHex} (length: ${mnemonic.entropyHex.length}))");
    debugPrint("entropyBinary: ${mnemonic.entropyBinary}");
    debugPrint("checksum: ${mnemonic.checksum}");

    debugPrint("words: ${mnemonic.words}");
    debugPrint("sentence: ${mnemonic.sentence}");
    debugPrint("seed: ${mnemonic.seed}");
    debugPrint("seedHex: ${mnemonic.seedHex}");

    final mnemonic2 =
        Mnemonic.fromEntropy(mnemonic.entropyHex, language: language);

    expect(mnemonic.entropy, mnemonic2.entropy);
    expect(mnemonic.entropyHex, mnemonic2.entropyHex);
    expect(mnemonic.entropyBinary, mnemonic2.entropyBinary);
    expect(mnemonic.checksum, mnemonic2.checksum);
    expect(mnemonic.words, mnemonic2.words);
    expect(mnemonic.sentence, mnemonic2.sentence);
    expect(mnemonic.seed, mnemonic2.seed);
    expect(mnemonic.seedHex, mnemonic2.seedHex);

    final mnemonic3 = Mnemonic.fromMnemonic(mnemonic.sentence);
    expect(mnemonic.entropy, mnemonic3.entropy);
    expect(mnemonic.entropyHex, mnemonic3.entropyHex);
    expect(mnemonic.entropyBinary, mnemonic3.entropyBinary);
    expect(mnemonic.checksum, mnemonic3.checksum);
    expect(mnemonic.words, mnemonic3.words);
    expect(mnemonic.sentence, mnemonic3.sentence);
    expect(mnemonic.seed, mnemonic3.seed);
    expect(mnemonic.seedHex, mnemonic3.seedHex);
  });

  group("construct mnemonic from invalid entropy", () {
    final invalidHex = vectors["invalid_entropy"]["hex"];
    for (var etropy in invalidHex) {
      test("string => $etropy", () {
        // expect exception message is "Invalid entropy hex string"
        expect(
            () => Mnemonic.fromEntropy(etropy),
            throwsA(predicate((e) =>
                e is Exception &&
                e.toString().contains("Invalid entropy hex string"))));
      });
    }

    final invalidLength = vectors["invalid_entropy"]["length"];
    for (var etropy in invalidLength) {
      test("length => $etropy", () {
        // expect exception message is "Invalid entropy hex length"
        expect(
            () => Mnemonic.fromEntropy(etropy),
            throwsA(predicate((e) =>
                e is Exception &&
                e.toString().contains("Invalid entropy hex length"))));
      });
    }
  });

  group("test construct", () {
    final mnemonics = vectors["mnemonic"];
    for (var mnemonic in mnemonics) {
      final language = mnemonic["language"];
      if (language == "unknown") continue;
      final entropy = mnemonic["entropy"];
      final sentence = mnemonic["mnemonic"];
      final passphrase = mnemonic["passphrase"];
      final seed = mnemonic["seed"];

      test("from mnemonic", () {
        final m = Mnemonic.fromMnemonic(sentence, passphrase: passphrase);
        expect(m.entropyHex, entropy);
        expect(m.seedHex, seed);
      });
    }

    for (var mnemonic in mnemonics) {
      final language = mnemonic["language"];
      if (language != "unknown") continue;
      // final entropy = mnemonic["entropy"];
      final sentence = mnemonic["mnemonic"];
      final passphrase = mnemonic["passphrase"];
      // final seed = mnemonic["seed"];

      // expect exception message is "Invalid mnemonic words with unknown language"
      test("from unknown language", () {
        expect(
            () => Mnemonic.fromMnemonic(sentence, passphrase: passphrase),
            throwsA(predicate((e) =>
                e is Exception &&
                e.toString().contains(
                    "Invalid mnemonic words with unknown language"))));
      });
    }
  });

  group("test construct from mnemonic", () {
    final mnemonics = vectors["invalid_mnemonic"];
    for (var mnemonic in mnemonics) {
      // expect exception message is "Invalid mnemonic words length"
      test("with invalid length", () {
        expect(
            () => Mnemonic.fromMnemonic(mnemonic),
            throwsA(predicate((e) =>
                e is Exception &&
                e.toString().contains("Invalid mnemonic words length"))));
      });
    }
  });
}
