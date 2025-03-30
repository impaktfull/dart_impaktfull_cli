import 'package:args/args.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/core/util/extensions/arg_result_extensions.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/command/dart/command/model/test_coverage_dart_config_data.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/util/test_coverage_ignore_util.dart';

class TestCoverageDartCommandConfig
    extends CommandConfig<TestCoverageDartConfigData> {
  static const String _optionRunTests = 'runTests';
  static const String _optionConvertToLcov = 'convertToLcov';
  static const String _optionOverrideLcovFile = 'overrideLcovFile';
  const TestCoverageDartCommandConfig();

  @override
  void addConfig(ArgParser argParser) {
    argParser.addFlag(
      _optionRunTests,
      help: 'Run tests before generating test coverage report',
      defaultsTo: true,
    );
    argParser.addFlag(
      _optionConvertToLcov,
      help: 'Convert test coverage report to lcov format',
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
  TestCoverageDartConfigData parseResult(ArgResults? argResults) =>
      TestCoverageDartConfigData(
        runTests: argResults.getFlag(_optionRunTests),
        convertToLcov: argResults.getFlag(_optionConvertToLcov),
        overrideLcovFile: argResults.getFlag(_optionOverrideLcovFile),
        ignorePatterns: TestCoverageIgnoreUtil.defaultIgnorePatterns,
      );
}
