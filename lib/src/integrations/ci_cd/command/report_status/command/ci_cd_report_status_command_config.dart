import 'package:args/args.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/core/util/extensions/arg_result_extensions.dart';
import 'package:impaktfull_cli/src/integrations/ci_cd/command/report_status/command/model/ci_cd_report_status_config_data.dart';

class CiCdReportStatusCommandConfig
    extends CommandConfig<CiCdReportStatusConfigData> {
  static const String _optionJobName = 'jobName';
  static const String _optionJobStatus = 'jobStatus';
  static const String _optionJobDuration = 'jobDuration';
  static const String _optionJobUrl = 'jobUrl';
  static const String _optionReportTo = 'reportTo';
  static const String optionSlackChannelName = 'slackChannelName';

  const CiCdReportStatusCommandConfig();

  @override
  void addConfig(ArgParser argParser) {
    argParser.addOption(
      _optionJobName,
      help: 'The name of the job to report the status of',
      mandatory: true,
    );
    argParser.addOption(
      _optionJobStatus,
      help: 'The status of the job',
      allowed: [
        'success',
        'failure',
        'cancelled',
      ],
      mandatory: true,
    );
    argParser.addOption(
      _optionJobDuration,
      help: 'The duration of the job',
    );
    argParser.addOption(
      _optionReportTo,
      help: 'The channel to report the status to',
      allowed: ['slack'],
      defaultsTo: 'slack',
    );
    argParser.addOption(
      _optionJobUrl,
      help: 'The URL of the job',
    );
    argParser.addOption(
      optionSlackChannelName,
      help: 'The name of the Slack channel to report the status to',
    );
  }

  @override
  CiCdReportStatusConfigData parseResult(ArgResults? argResults) =>
      CiCdReportStatusConfigData(
        jobName: argResults.getRequiredOption(_optionJobName),
        jobStatus: argResults.getRequiredOption(_optionJobStatus),
        jobDuration: argResults.getOption(_optionJobDuration),
        reportTo: argResults.getRequiredOption(_optionReportTo),
        jobUrl: argResults.getOption(_optionJobUrl),
        slackChannelName: argResults.getOption(optionSlackChannelName),
      );
}
