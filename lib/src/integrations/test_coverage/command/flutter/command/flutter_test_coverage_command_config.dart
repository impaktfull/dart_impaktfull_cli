import 'package:args/args.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/command/flutter/command/model/flutter_test_coverage_config_data.dart';

class FlutterTestCoverageCommandConfig
    extends CommandConfig<FlutterTestCoverageConfigData> {
  const FlutterTestCoverageCommandConfig();

  @override
  void addConfig(ArgParser argParser) {}

  @override
  FlutterTestCoverageConfigData parseResult(ArgResults? argResults) =>
      FlutterTestCoverageConfigData();
}
