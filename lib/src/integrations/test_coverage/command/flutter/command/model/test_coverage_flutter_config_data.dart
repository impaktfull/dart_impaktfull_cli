import 'package:impaktfull_cli/src/core/command/config/command_config.dart';

class TestCoverageFlutterConfigData extends ConfigData {
  final bool runTests;
  final List<RegExp> ignorePatterns;
  final bool overrideLcovFile;

  const TestCoverageFlutterConfigData({
    required this.runTests,
    required this.ignorePatterns,
    required this.overrideLcovFile,
  });
}
