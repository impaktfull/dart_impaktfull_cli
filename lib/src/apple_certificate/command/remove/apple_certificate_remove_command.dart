import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/apple_certificate/command/apple_certificate_root_command.dart';
import 'package:impaktfull_cli/src/apple_certificate/command/remove/apple_certificate_remove_command_config.dart';
import 'package:impaktfull_cli/src/apple_certificate/model/remove/apple_certificate_remove_config_data.dart';
import 'package:impaktfull_cli/src/cli/command/command/cli_command.dart';
import 'package:impaktfull_cli/src/cli/command/config/command_config.dart';

class AppleCertificateRemoveCommand extends CliCommand<AppleCertificateRemoveConfigData> {
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
  CommandConfig<AppleCertificateRemoveConfigData> getConfig() => AppleCertificateRemoveCommandConfig(
        defaultKeyChainName: util.defaultKeyChainName,
      );

  @override
  Future<void> runCommand(AppleCertificateRemoveConfigData configData) async {
    final keyChainPlugin = MacOsKeyChainPlugin();
    await keyChainPlugin.removeKeyChain(configData.keyChainName);
  }
}
