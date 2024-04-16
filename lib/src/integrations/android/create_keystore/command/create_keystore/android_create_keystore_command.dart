import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/core/command/command/cli_command.dart';
import 'package:impaktfull_cli/src/integrations/android/create_keystore/command/create_keystore/android_create_keystore_command_config.dart';
import 'package:impaktfull_cli/src/integrations/android/create_keystore/command/create_keystore/model/android_create_keystore_config_data.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/integrations/android/create_keystore/plugin/android_create_keystore_plugin.dart';

class AndroidCreateKeystoreCommand
    extends CliCommand<AndroidCreateKeyStoreConfigData> {
  AndroidCreateKeystoreCommand({
    required super.processRunner,
  });

  @override
  String get name => 'create_keystore';

  @override
  String get description => 'Create a keystore';

  @override
  CommandConfig<AndroidCreateKeyStoreConfigData> getConfig() =>
      AndroidCreateKeyStoreCommandConfig();

  @override
  Future<void> runCommand(AndroidCreateKeyStoreConfigData configData) async {
    final androidCreateKeyStorePlugin =
        AndroidCreateKeyStorePlugin(processRunner: processRunner);
    for (final name in configData.configNames) {
      ImpaktfullCliLogger.startSpinner('Creating keystore for $name');
      await androidCreateKeyStorePlugin.createKeyStore(
        name: name,
        fullName: configData.fullName,
        organization: configData.organization,
        organizationUnit: configData.organizationUnit,
        city: configData.city,
        state: configData.state,
        country: configData.country,
      );
    }
  }
}
