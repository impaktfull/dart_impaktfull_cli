import 'package:args/command_runner.dart';
import 'package:impaktfull_cli/src/core/command/command/root_command.dart';
import 'package:impaktfull_cli/src/integrations/ci_cd/command/report_status/command/ci_cd_report_status_command.dart';

class CiCdRootCommand extends RootCommand {
  @override
  String get name => 'ci_cd';

  @override
  String get description => 'Commands for CI/CD integrations.';

  CiCdRootCommand({
    required super.processRunner,
  });

  @override
  List<Command<dynamic>> getSubCommands() {
    return [
      CiCdReportStatusCommand(processRunner: processRunner),
    ];
  }
}
