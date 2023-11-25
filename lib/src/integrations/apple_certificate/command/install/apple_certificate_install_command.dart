import 'package:impaktfull_cli/src/integrations/apple_certificate/command/apple_certificate_root_command.dart';
import 'package:impaktfull_cli/src/integrations/apple_certificate/command/install/apple_certificate_install_command_config.dart';
import 'package:impaktfull_cli/src/integrations/apple_certificate/model/install/apple_certificate_install_config_data.dart';
import 'package:impaktfull_cli/src/core/command/command/cli_command.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';

class AppleCertificateInstallCommand
    extends CliCommand<AppleCertificateInstallConfigData> {
  final AppleCertificateUtil util;

  AppleCertificateInstallCommand({
    required super.processRunner,
    required this.util,
  });

  @override
  String get name => 'install';

  @override
  String get description => 'Install Apple certificates into the keychain.';

  @override
  CommandConfig<AppleCertificateInstallConfigData> getConfig() =>
      AppleCertificateInstallCommandConfig(
        defaultKeyChainName: util.defaultKeyChainName,
      );

  @override
  Future<void> runCommand(AppleCertificateInstallConfigData configData) async {}
}
