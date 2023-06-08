# dart_mnemonic

Reference implementation of [BIP-0039](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki) for the Dart language. This library is used to generate crypto wallet mnemonic phrases and derive HD wallet root seed from those phrases.

## Features

Support for all existing [BIP-0039 Wordlists](https://github.com/bitcoin/bips/blob/master/bip-0039/bip-0039-wordlists.md).

## Getting started

### Use this package as a library

Depend on it

Run this command:

With Dart:

```sh
dart pub add dart_mnemonic
```

With Flutter:

```sh
flutter pub add dart_mnemonic
```

This will add a line like this to your package's pubspec.yaml (and run an implicit `dart pub get`):

```sh
dependencies:
  dart_mnemonic: ^latest
```

Alternatively, your editor might support dart pub get or flutter pub get. Check the docs for your editor to learn more.

### Import it

Now in your Dart code, you can use:

```dart
import 'package:dart_mnemonic/dart_mnemonic.dart';
```

## Usage

```dart
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
    var m3 = Mnemonic.fromMnemonic("beef winner bread entry item penalty spoil vivid whale over bachelor net");
    debugPrint("entropy: ${m3.entropyHex}");
    // => entropy: 141f7c6da5d76d453497a9f9b3bc44ca
    debugPrint("words: ${m3.words}");
    // => words: [beef, winner, bread, entry, item, penalty, spoil, vivid, whale, over, bachelor, net]
    debugPrint("sentence: ${m3.sentence}");
    // => beef winner bread entry item penalty spoil vivid whale over bachelor net
    debugPrint("seed: ${m3.seedHex}");
    // => seed: cc9441bf020f9b45ad920404ee8a40139dc8cf1eca9ee5720743c4ae2a085c391fede2e19cd4fe345f12767ee8829f3cfb5d2e041ddbbc14d072e568ac506e69

    // Generate a mnemonic in Japanese with a passphrase and a word count of 24
    var m4 = Mnemonic(language: Language.japanese, passphrase: "passphrase", length: 24);
    debugPrint("entropy: ${m4.entropyHex}");
    debugPrint("words: ${m4.words}");
    debugPrint("sentence: ${m4.sentence}");
    debugPrint("seed: ${m4.seedHex}");
```

## Additional information

If you have any problems or bugs in use, please contact us.
