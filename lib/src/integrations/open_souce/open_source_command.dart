import 'package:args/command_runner.dart';
import 'package:impaktfull_cli/src/core/command/command/root_command.dart';
import 'package:impaktfull_cli/src/integrations/open_souce/command/report_new_release/command/open_source_report_new_release_command.dart';

class OpenSourceRootCommand extends RootCommand {
  @override
  String get name => 'open_source';

  @override
  String get description => 'Commands for open source projects.';

  OpenSourceRootCommand({
    required super.processRunner,
  });

  @override
  List<Command<dynamic>> getSubCommands() {
    return [
      OpenSourceReportNewReleaseCommand(processRunner: processRunner),
    ];
  }
}
