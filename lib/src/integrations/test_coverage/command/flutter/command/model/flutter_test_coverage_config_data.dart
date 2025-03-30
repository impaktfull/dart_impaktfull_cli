import 'package:impaktfull_cli/src/core/command/config/command_config.dart';

class FlutterTestCoverageConfigData extends ConfigData {
  final bool runTests;
  final List<RegExp> ignorePatterns;
  final bool overrideLcovFile;

  const FlutterTestCoverageConfigData({
    required this.runTests,
    required this.ignorePatterns,
    required this.overrideLcovFile,
  });
}
