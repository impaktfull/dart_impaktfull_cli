import 'package:impaktfull_cli/src/core/command/config/command_config.dart';

class FlutterTestCoverageConfigData extends ConfigData {
  final bool runTests;

  const FlutterTestCoverageConfigData({
    this.runTests = true,
  });
}
