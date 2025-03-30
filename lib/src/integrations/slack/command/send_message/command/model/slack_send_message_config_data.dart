import 'package:impaktfull_cli/src/core/command/config/command_config.dart';

class SlackSendMessageConfigData extends ConfigData {
  final String message;
  final String channelName;

  const SlackSendMessageConfigData({
    required this.message,
    required this.channelName,
  });
}
