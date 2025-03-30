import 'package:args/args.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/command/dart/command/model/dart_test_coverage_config_data.dart';

class FlutterTestCoverageCommandConfig
    extends CommandConfig<DartTestCoverageConfigData> {
  const FlutterTestCoverageCommandConfig();

  @override
  void addConfig(ArgParser argParser) {}

  @override
  DartTestCoverageConfigData parseResult(ArgResults? argResults) =>
      DartTestCoverageConfigData();
}
