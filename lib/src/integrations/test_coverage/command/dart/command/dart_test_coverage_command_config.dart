import 'package:args/args.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/core/util/extensions/arg_result_extensions.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/command/dart/command/model/dart_test_coverage_config_data.dart';

class DartTestCoverageCommandConfig
    extends CommandConfig<DartTestCoverageConfigData> {
  static const String _optionRunTests = 'runTests';
  static const String _optionConvertToLcov = 'convertToLcov';

  const DartTestCoverageCommandConfig();

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
  }

  @override
  DartTestCoverageConfigData parseResult(ArgResults? argResults) =>
      DartTestCoverageConfigData(
        runTests: argResults.getFlag(_optionRunTests),
        convertToLcov: argResults.getFlag(_optionConvertToLcov),
        ignorePatterns: [
          RegExp(r'.*\.g\.dart$'),
          RegExp(r'.*\.navigator\.dart$'),
          RegExp(r'.*/injectable\.config\.dart$'),
        ],
      );
}
