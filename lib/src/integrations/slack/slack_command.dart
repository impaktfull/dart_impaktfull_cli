import 'package:args/command_runner.dart';
import 'package:impaktfull_cli/src/core/command/command/root_command.dart';
import 'package:impaktfull_cli/src/integrations/slack/command/send_message/command/slack_send_message_command.dart';

class SlackRootCommand extends RootCommand {
  @override
  String get name => 'slack';

  @override
  String get description => 'Commands for Slack integrations.';

  SlackRootCommand({
    required super.processRunner,
  });

  @override
  List<Command<dynamic>> getSubCommands() {
    return [
      SlackSendMessageCommand(processRunner: processRunner),
    ];
  }
}
