import 'package:impaktfull_cli/src/core/command/command/cli_command.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_appstore/command/upload/command/impaktfull_appstore_upload_command_config.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_appstore/command/upload/command/model/impaktfull_appstore_upload_config_data.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_appstore/model/impaktfull_appstore_credentials.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_appstore/model/impaktfull_appstore_upload_config.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_appstore/plugin/impaktfull_appstore_plugin.dart';

/// `impaktfull_cli appstore upload`: the invocation the appstore's CI setup
/// page shows. The upload key is read from `IMPAKTFULL_APPSTORE_UPLOAD_KEY`,
/// never from a flag, so it does not end up in a shell history or a CI log.
class ImpaktfullAppstoreUploadCommand
    extends CliCommand<ImpaktfullAppstoreUploadConfigData> {
  ImpaktfullAppstoreUploadCommand({
    required super.processRunner,
  });

  @override
  String get name => 'upload';

  @override
  String get description =>
      'Upload an .ipa or .apk to the impaktfull appstore (the upload key is '
      'read from `IMPAKTFULL_APPSTORE_UPLOAD_KEY`)';

  @override
  CommandConfig<ImpaktfullAppstoreUploadConfigData> getConfig() =>
      const ImpaktfullAppstoreUploadCommandConfig();

  @override
  Future<void> runCommand(ImpaktfullAppstoreUploadConfigData configData) async {
    final plugin = ImpaktfullAppstorePlugin(processRunner: processRunner);
    await plugin.uploadToImpaktfullAppstore(
      file: configData.file,
      config: ImpaktfullAppstoreUploadConfig(
        credentials: ImpaktfullAppstoreCredentials.fromEnvironment(),
        environmentName: configData.environmentName,
        releaseNotes: configData.releaseNotes,
        waitForProcessing: configData.waitForProcessing,
        baseUrl: configData.baseUrl,
      ),
    );
  }
}
