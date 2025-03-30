import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/core/command/command/cli_command.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/integrations/slack/command/send_message/command/model/slack_send_message_config_data.dart';
import 'package:impaktfull_cli/src/integrations/slack/command/send_message/command/slack_send_message_command_config.dart';
import 'package:impaktfull_cli/src/integrations/slack/plugin/slack_plugin.dart';

class SlackSendMessageCommand extends CliCommand<SlackSendMessageConfigData> {
  SlackSendMessageCommand({
    required super.processRunner,
  });

  @override
  String get name => 'send_message';

  @override
  String get description => 'Send a message to Slack';

  @override
  CommandConfig<SlackSendMessageConfigData> getConfig() =>
      SlackSendMessageCommandConfig();

  @override
  Future<void> runCommand(SlackSendMessageConfigData configData) async {
    final plugin = SlackPlugin(processRunner: processRunner);
    ImpaktfullCliLogger.log('Sending message to Slack...');
    await plugin.sendMessage(
      message: configData.message,
      channelName: configData.channelName,
    );
    ImpaktfullCliLogger.endSpinner();
  }
}
