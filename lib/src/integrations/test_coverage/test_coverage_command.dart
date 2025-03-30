import 'package:args/command_runner.dart';
import 'package:impaktfull_cli/src/core/command/command/root_command.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/command/dart/command/test_coverage_dart_command.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/command/flutter/command/test_coverage_flutter_command.dart';

class TestCoverageRootCommand extends RootCommand {
  @override
  String get name => 'test_coverage';

  @override
  String get description => 'Commands for test coverage integrations.';

  TestCoverageRootCommand({
    required super.processRunner,
  });

  @override
  List<Command<dynamic>> getSubCommands() {
    return [
      TestCoverageFlutterCommand(processRunner: processRunner),
      TestCoverageDartCommand(processRunner: processRunner),
    ];
  }
}
