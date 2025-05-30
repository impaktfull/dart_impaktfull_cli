import 'package:impaktfull_cli/src/integrations/apple/certificate/command/apple_certificate_root_command.dart';
import 'package:impaktfull_cli/src/integrations/apple/certificate/command/remove/apple_certificate_remove_command_config.dart';
import 'package:impaktfull_cli/src/integrations/apple/certificate/model/remove/apple_certificate_remove_config_data.dart';
import 'package:impaktfull_cli/src/core/command/command/cli_command.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/integrations/apple/certificate/plugin/mac_os_keychain_plugin.dart';

class AppleCertificateRemoveCommand
    extends CliCommand<AppleCertificateRemoveConfigData> {
  final AppleCertificateUtil util;

  AppleCertificateRemoveCommand({
    required super.processRunner,
    required this.util,
  });

  @override
  String get name => 'remove';

  @override
  String get description => 'Remove Apple certificates from the keychain';

  @override
  CommandConfig<AppleCertificateRemoveConfigData> getConfig() =>
      AppleCertificateRemoveCommandConfig(
        defaultKeyChainName: util.defaultKeyChainName,
      );

  @override
  Future<void> runCommand(AppleCertificateRemoveConfigData configData) async {
    final keyChainPlugin = MacOsKeyChainPlugin(processRunner: processRunner);
    await keyChainPlugin.removeKeyChain(configData.keyChainName);
  }
}
