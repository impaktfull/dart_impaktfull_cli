import 'package:args/args.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/core/util/extensions/arg_result_extensions.dart';
import 'package:impaktfull_cli/src/integrations/open_souce/command/report_new_release/command/model/open_source_report_new_release_config_data.dart';

class OpenSourceReportNewReleaseCommandConfig
    extends CommandConfig<OpenSourceReportNewReleaseConfigData> {
  static const String _optionPackageName = 'packageName';
  static const String _optionPackageVersion = 'packageVersion';
  static const String _optionPackageChangeLog = 'packageChangeLog';
  static const String _optionReportTo = 'reportTo';
  static const String _optionSlackChannelName = 'slackChannelName';

  const OpenSourceReportNewReleaseCommandConfig();

  @override
  void addConfig(ArgParser argParser) {
    argParser.addOption(
      _optionPackageName,
      help: 'The name of the package to report the new release of',
      mandatory: true,
    );
    argParser.addOption(
      _optionPackageVersion,
      help: 'The version of the new release',
      mandatory: true,
    );
    argParser.addOption(
      _optionPackageChangeLog,
      help: 'The changelog of the new release',
    );
    argParser.addOption(
      _optionReportTo,
      help: 'The channel to report the new release to',
      allowed: ['slack'],
      defaultsTo: 'slack',
    );
    argParser.addOption(
      _optionSlackChannelName,
      help:
          'The name of the Slack channel to report the new release to (defaults to open-source-{packageName in kebab-case})',
    );
  }

  @override
  OpenSourceReportNewReleaseConfigData parseResult(ArgResults? argResults) =>
      OpenSourceReportNewReleaseConfigData(
        packageName: argResults.getRequiredOption(_optionPackageName),
        packageVersion: argResults.getRequiredOption(_optionPackageVersion),
        packageChangeLog: argResults.getOption(_optionPackageChangeLog),
        reportTo: argResults.getRequiredOption(_optionReportTo),
        slackChannelName: argResults.getOption(_optionSlackChannelName),
      );
}
