import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/core/command/command/cli_command.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/command/flutter/command/test_coverage_flutter_command_config.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/command/flutter/command/model/test_coverage_flutter_config_data.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/model/test_coverage_type.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/plugin/test_coverage_plugin.dart';

class TestCoverageFlutterCommand
    extends CliCommand<TestCoverageFlutterConfigData> {
  TestCoverageFlutterCommand({
    required super.processRunner,
  });

  @override
  String get name => 'flutter';

  @override
  String get description =>
      'Create a test coverage report for a Flutter project (after lcov.info is already generated)';

  @override
  CommandConfig<TestCoverageFlutterConfigData> getConfig() =>
      TestCoverageFlutterCommandConfig();

  @override
  Future<void> runCommand(TestCoverageFlutterConfigData configData) async {
    final testCoveragePlugin = TestCoveragePlugin(processRunner: processRunner);
    if (configData.runTests) {
      ImpaktfullCliLogger.startSpinner('Running tests...');
      await processRunner.runProcess([
        if (ImpaktfullCliEnvironment.instance.isFvmProject) ...[
          'fvm',
        ],
        'flutter',
        'test',
        '--coverage',
      ]);
      ImpaktfullCliLogger.endSpinner();
    }

    ImpaktfullCliLogger.startSpinner('Generating test coverage report...');
    final lcovFile = await testCoveragePlugin.testCoverage(
      path: '.',
      type: TestCoverageType.lcovInfo,
      overrideLcovFile: configData.overrideLcovFile,
      ignorePatterns: configData.ignorePatterns,
    );
    ImpaktfullCliLogger.endSpinner();
    ImpaktfullCliLogger.log(lcovFile.printReport('Flutter'));
  }
}
