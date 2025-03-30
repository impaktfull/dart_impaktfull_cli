import 'package:impaktfull_cli/src/core/command/config/command_config.dart';

class CiCdReportStatusConfigData extends ConfigData {
  final String jobName;
  final String jobStatus;
  final String reportTo;
  final String? jobUrl;
  final int? jobDuration;
  final String? slackChannelName;

  const CiCdReportStatusConfigData({
    required this.jobName,
    required this.jobStatus,
    required this.jobDuration,
    required this.reportTo,
    this.jobUrl,
    this.slackChannelName,
  });
}
