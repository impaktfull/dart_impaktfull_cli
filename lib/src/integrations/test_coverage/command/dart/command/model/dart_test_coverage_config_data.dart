import 'package:impaktfull_cli/src/core/command/config/command_config.dart';

class DartTestCoverageConfigData extends ConfigData {
  final bool runTests;
  final bool convertToLcov;

  const DartTestCoverageConfigData({
    this.runTests = true,
    this.convertToLcov = true,
  });
}
