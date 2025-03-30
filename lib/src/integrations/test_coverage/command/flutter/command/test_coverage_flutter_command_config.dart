import 'package:args/args.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/core/util/extensions/arg_result_extensions.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/command/flutter/command/model/test_coverage_flutter_config_data.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/util/test_coverage_ignore_util.dart';

class TestCoverageFlutterCommandConfig
    extends CommandConfig<TestCoverageFlutterConfigData> {
  static const String _optionRunTests = 'runTests';
  static const String _optionOverrideLcovFile = 'overrideLcovFile';
  const TestCoverageFlutterCommandConfig();

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
  TestCoverageFlutterConfigData parseResult(ArgResults? argResults) =>
      TestCoverageFlutterConfigData(
        runTests: argResults.getFlag(_optionRunTests),
        overrideLcovFile: argResults.getFlag(_optionOverrideLcovFile),
        ignorePatterns: TestCoverageIgnoreUtil.defaultIgnorePatterns,
      );
}
