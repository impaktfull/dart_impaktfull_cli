import 'package:args/args.dart';
import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/core/util/extensions/arg_result_extensions.dart';
import 'package:impaktfull_cli/src/integrations/slack/command/send_message/command/model/slack_send_message_config_data.dart';

class SlackSendMessageCommandConfig
    extends CommandConfig<SlackSendMessageConfigData> {
  static const String _optionMessage = 'message';
  static const String _optionChannelName = 'channelName';
  const SlackSendMessageCommandConfig();

  @override
  void addConfig(ArgParser argParser) {
    argParser.addOption(
      _optionMessage,
      help: 'The message to send to Slack',
      mandatory: true,
    );
    argParser.addOption(
      _optionChannelName,
      help:
          'The channel to send the message to (if empty `${ImpaktfullCliEnvironmentVariables.envKeySlackSendMessageChannel}` env variable should be set)',
    );
  }

  @override
  SlackSendMessageConfigData parseResult(ArgResults? argResults) =>
      SlackSendMessageConfigData(
        message: argResults.getRequiredOption(_optionMessage),
        channelName: argResults.getRequiredOptionOrEnvVariable(
            _optionChannelName,
            ImpaktfullCliEnvironmentVariables.envKeySlackSendMessageChannel),
      );
}
