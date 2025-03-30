import 'package:impaktfull_cli/src/core/command/config/command_config.dart';

class DartTestCoverageConfigData extends ConfigData {
  final bool runTests;
  final bool convertToLcov;
  final List<RegExp> ignorePatterns;

  const DartTestCoverageConfigData({
    required this.runTests,
    required this.convertToLcov,
    required this.ignorePatterns,
  });
}
