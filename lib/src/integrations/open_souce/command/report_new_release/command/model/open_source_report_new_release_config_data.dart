import 'package:impaktfull_cli/src/core/command/config/command_config.dart';

class OpenSourceReportNewReleaseConfigData extends ConfigData {
  final String packageName;
  final String packageVersion;
  final String reportTo;
  final String? packageChangeLog;
  final String? slackChannelName;

  const OpenSourceReportNewReleaseConfigData({
    required this.packageName,
    required this.packageVersion,
    required this.reportTo,
    this.packageChangeLog,
    this.slackChannelName,
  });
}
