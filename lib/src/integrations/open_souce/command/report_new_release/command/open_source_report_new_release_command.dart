import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/core/command/command/cli_command.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/core/util/case/case_util.dart';
import 'package:impaktfull_cli/src/integrations/open_souce/command/report_new_release/command/open_source_report_new_release_command_config.dart';
import 'package:impaktfull_cli/src/integrations/open_souce/command/report_new_release/command/model/open_source_report_new_release_config_data.dart';
import 'package:impaktfull_cli/src/integrations/slack/model/slack_message_attachment.dart';
import 'package:impaktfull_cli/src/integrations/slack/plugin/slack_plugin.dart';

class OpenSourceReportNewReleaseCommand
    extends CliCommand<OpenSourceReportNewReleaseConfigData> {
  OpenSourceReportNewReleaseCommand({
    required super.processRunner,
  });

  @override
  String get name => 'report_new_release';

  @override
  String get description =>
      'Report the new release to the open source repository';

  @override
  CommandConfig<OpenSourceReportNewReleaseConfigData> getConfig() =>
      OpenSourceReportNewReleaseCommandConfig();

  @override
  Future<void> runCommand(
      OpenSourceReportNewReleaseConfigData configData) async {
    ImpaktfullCliLogger.log('Preparing report message');
    var message =
        'New version of ${configData.packageName} was released to pub.dev: `${configData.packageVersion}`';
    if (configData.packageChangeLog != null) {
      message += '\nCHANGELOG:\n\n${configData.packageChangeLog}';
    }
    ImpaktfullCliLogger.log('Sending ci/cd status to Slack');
    await sendSlackMessage(message, configData);
  }

  Future<void> sendSlackMessage(
      String message, OpenSourceReportNewReleaseConfigData configData) async {
    final plugin = SlackPlugin(processRunner: processRunner);
    final attachments = [
      SlackMessageAttachment(
        text: message,
        color: '#00b330',
      ),
    ];
    final channelName = configData.slackChannelName ??
        'open-source-${CaseUtil.snakeCaseToKebabCase(configData.packageName)}';
    await plugin.sendMessage(
      channelName: channelName,
      attachments: attachments,
    );
  }
}
