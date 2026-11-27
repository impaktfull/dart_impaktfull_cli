import 'dart:io';

import 'package:args/args.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/core/util/extensions/arg_result_extensions.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_appstore/command/upload/command/model/impaktfull_appstore_upload_config_data.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_appstore/model/impaktfull_appstore_upload_config.dart';

class ImpaktfullAppstoreUploadCommandConfig
    extends CommandConfig<ImpaktfullAppstoreUploadConfigData> {
  static const String _optionFile = 'file';
  static const String _optionEnvironment = 'environment';
  static const String _optionUrl = 'url';
  static const String _optionReleaseNotes = 'releaseNotes';
  static const String _flagWait = 'wait';

  const ImpaktfullAppstoreUploadCommandConfig();

  @override
  void addConfig(ArgParser argParser) {
    argParser.addOption(
      _optionFile,
      help: 'The .ipa or .apk to upload',
      mandatory: true,
    );
    argParser.addOption(
      _optionEnvironment,
      help:
          'The environment name, e.g. `staging`. The platform comes from the '
          'file extension.',
      mandatory: true,
    );
    argParser.addOption(
      _optionUrl,
      help: 'The appstore to upload to',
      defaultsTo: ImpaktfullAppstoreUploadConfig.defaultBaseUrl.toString(),
    );
    argParser.addOption(
      _optionReleaseNotes,
      help: 'Release notes shown to testers',
    );
    argParser.addFlag(
      _flagWait,
      help:
          'Wait until the appstore has validated the build, and fail when it '
          'rejects it',
      defaultsTo: true,
    );
  }

  @override
  ImpaktfullAppstoreUploadConfigData parseResult(ArgResults? argResults) {
    final url = argResults.getRequiredOption<String>(_optionUrl);
    final baseUrl = Uri.tryParse(url);
    if (baseUrl == null || !baseUrl.hasScheme || baseUrl.host.isEmpty) {
      throw ArgumentError('`$url` is not a valid url for --$_optionUrl');
    }
    final releaseNotes = argResults.getOption<String>(_optionReleaseNotes);
    return ImpaktfullAppstoreUploadConfigData(
      file: File(argResults.getRequiredOption<String>(_optionFile)),
      environmentName: argResults.getRequiredOption<String>(_optionEnvironment),
      baseUrl: baseUrl,
      releaseNotes: releaseNotes == null || releaseNotes.trim().isEmpty
          ? null
          : releaseNotes,
      waitForProcessing: argResults.getFlag(_flagWait),
    );
  }
}
