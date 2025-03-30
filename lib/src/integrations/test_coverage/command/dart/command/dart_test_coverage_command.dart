import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/core/command/command/cli_command.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/command/dart/command/dart_test_coverage_command_config.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/command/dart/command/model/dart_test_coverage_config_data.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/model/test_coverage_type.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/plugin/test_coverage_plugin.dart';

class DartTestCoverageCommand extends CliCommand<DartTestCoverageConfigData> {
  DartTestCoverageCommand({
    required super.processRunner,
  });

  @override
  String get name => 'dart';

  @override
  String get description =>
      'Create a test coverage report for a Dart project (after lcov.info is already generated)';

  @override
  CommandConfig<DartTestCoverageConfigData> getConfig() =>
      DartTestCoverageCommandConfig();

  @override
  Future<void> runCommand(DartTestCoverageConfigData configData) async {
    final testCoveragePlugin = TestCoveragePlugin(processRunner: processRunner);

    if (configData.runTests) {
      ImpaktfullCliLogger.startSpinner('Running tests...');
      await processRunner.runProcess([
        if (ImpaktfullCliEnvironment.instance.isFvmProject) ...[
          'fvm',
        ],
        'dart',
        'test',
        '--coverage=coverage',
      ]);
      ImpaktfullCliLogger.endSpinner();
    }
    if (configData.convertToLcov) {
      ImpaktfullCliLogger.startSpinner('Converting to lcov...');
      await processRunner.runProcess([
        if (ImpaktfullCliEnvironment.instance.isFvmProject) ...[
          'fvm',
        ],
        'dart',
        'run',
        'coverage:format_coverage',
        '--lcov',
        '--in=coverage',
        '--out=coverage/lcov.info',
        '--report-on=lib',
      ]);
    }

    final ignorePatterns = [
      RegExp(r'.*\.g\.dart$'),
      RegExp(r'.*\.navigator\.dart$'),
      RegExp(r'.*/injectable\.config\.dart$'),
    ];

    ImpaktfullCliLogger.startSpinner('Generating test coverage report...');
    final lcovFile = await testCoveragePlugin.testCoverage(
      path: '.',
      type: TestCoverageType.lcovInfo,
      ignorePatterns: ignorePatterns,
    );
    ImpaktfullCliLogger.endSpinner();
    ImpaktfullCliLogger.log(lcovFile.printReport('Flutter'));
  }
}
