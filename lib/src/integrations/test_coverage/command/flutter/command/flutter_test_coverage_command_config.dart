import 'package:args/args.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/core/util/extensions/arg_result_extensions.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/command/flutter/command/model/flutter_test_coverage_config_data.dart';

class FlutterTestCoverageCommandConfig
    extends CommandConfig<FlutterTestCoverageConfigData> {
  static const String _optionRunTests = 'runTests';
  static const String _optionOverrideLcovFile = 'overrideLcovFile';
  const FlutterTestCoverageCommandConfig();

  @override
  void addConfig(ArgParser argParser) {
    argParser.addFlag(
      _optionRunTests,
      help: 'Run tests before generating test coverage report',
      defaultsTo: true,
    );
    argParser.addFlag(
      _optionOverrideLcovFile,
      help:
          'Override the lcov file changes were made because of the `ignorePatterns`',
      defaultsTo: true,
    );
  }

  @override
  FlutterTestCoverageConfigData parseResult(ArgResults? argResults) =>
      FlutterTestCoverageConfigData(
        runTests: argResults.getFlag(_optionRunTests),
        overrideLcovFile: argResults.getFlag(_optionOverrideLcovFile),
        ignorePatterns: [
          RegExp(r'.*\.g\.dart$'),
          RegExp(r'.*\.navigator\.dart$'),
          RegExp(r'.*/injectable\.config\.dart$'),
        ],
      );
}
