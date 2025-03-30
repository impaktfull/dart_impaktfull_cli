import 'package:args/command_runner.dart';
import 'package:impaktfull_cli/src/core/command/command/root_command.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/command/dart/command/dart_test_coverage_command.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/command/flutter/command/flutter_test_coverage_command.dart';

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
      DartTestCoverageCommand(processRunner: processRunner),
      FlutterTestCoverageCommand(processRunner: processRunner),
    ];
  }
}
