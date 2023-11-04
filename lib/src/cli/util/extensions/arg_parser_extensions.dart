import 'package:args/args.dart';

extension ArgsParserExtension on ArgParser {
  static const verboseFlag = 'verbose';

  void addGlobalFlags() {
    addFlag(verboseFlag,
        abbr: 'v', help: 'Show extra logging', defaultsTo: false);
  }
}
