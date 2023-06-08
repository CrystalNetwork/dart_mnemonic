import 'package:unorm_dart/unorm_dart.dart';

import 'wordlist/chinese_simplified.dart';
import 'wordlist/chinese_traditional.dart';
import 'wordlist/czech.dart';
import 'wordlist/english.dart';
import 'wordlist/french.dart';
import 'wordlist/italian.dart';
import 'wordlist/japanese.dart';
import 'wordlist/korean.dart';
import 'wordlist/portuguese.dart';
import 'wordlist/spanish.dart';

enum Language {
  // ignore: constant_identifier_names
  chinese_simplified("Chinese simplified", zhCN),
  // ignore: constant_identifier_names
  chinese_traditional("Chinese traditional", zhTW),
  czech("Czech", cs),
  english("English", en),
  french("French", fr),
  italian("Italian", it),
  japanese("Japanese", ja),
  korean("Korean", ko),
  portuguese("Portuguese", pt),
  spanish("Spanish", es),
  unknown("Unknown", []);

  final String language;
  final List<String> _wordlist;
  const Language(this.language, this._wordlist);

  List<String> get wordlist => _wordlist;

  Map<int, String> get map => wordlist.asMap();

  String get delimiter => this == Language.japanese ? '\u{3000}' : "\u{0020}";

  bool isValidWord(String word) {
    return wordlist.contains(nfkd(word));
  }
}
