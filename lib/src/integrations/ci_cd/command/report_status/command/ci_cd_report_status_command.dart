import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/core/command/command/cli_command.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/integrations/ci_cd/command/report_status/command/ci_cd_report_status_command_config.dart';
import 'package:impaktfull_cli/src/integrations/ci_cd/command/report_status/command/model/ci_cd_report_status_config_data.dart';
import 'package:impaktfull_cli/src/integrations/slack/model/slack_message_attachment.dart';
import 'package:impaktfull_cli/src/integrations/slack/plugin/slack_plugin.dart';

class CiCdReportStatusCommand extends CliCommand<CiCdReportStatusConfigData> {
  CiCdReportStatusCommand({
    required super.processRunner,
  });

  @override
  String get name => 'report_status';

  @override
  String get description => 'Report the status of a job';

  @override
  CommandConfig<CiCdReportStatusConfigData> getConfig() =>
      CiCdReportStatusCommandConfig();

  @override
  Future<void> runCommand(CiCdReportStatusConfigData configData) async {
    ImpaktfullCliLogger.log('Preparing report message');
    var message =
        '${configData.jobName} completed with status: `${configData.jobStatus}`';
    if (configData.jobUrl != null) {
      message += '\n👉 <${configData.jobUrl}|View Job>';
    }
    ImpaktfullCliLogger.log('Sending ci/cd status to Slack');
    await sendSlackMessage(message, configData);
  }

  Future<void> sendSlackMessage(
      String message, CiCdReportStatusConfigData configData) async {
    final plugin = SlackPlugin(processRunner: processRunner);
    final attachments = [
      SlackMessageAttachment(
        text: message,
        color: configData.jobStatus == 'success' ? '#00b330' : '#cc0000',
      ),
    ];
    final channelName = configData.slackChannelName;
    if (channelName == null) {
      throw ImpaktfullCliError(
          '`${CiCdReportStatusCommandConfig.optionSlackChannelName}` is required');
    }
    await plugin.sendMessage(
      channelName: channelName,
      attachments: attachments,
    );
  }
}
