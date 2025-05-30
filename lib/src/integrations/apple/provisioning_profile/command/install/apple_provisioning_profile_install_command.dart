import 'package:impaktfull_cli/src/core/command/command/cli_command.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/integrations/apple/provisioning_profile/command/install/apple_provisioning_profile_install_command_config.dart';
import 'package:impaktfull_cli/src/integrations/apple/provisioning_profile/model/install/apple_provisioning_profile_install_config_data.dart';
import 'package:impaktfull_cli/src/integrations/apple/provisioning_profile/plugin/apple_provisioning_profile_plugin.dart';

class AppleProvisioningProfileInstallCommand
    extends CliCommand<AppleProvisioningProfileInstallConfigData> {
  AppleProvisioningProfileInstallCommand({
    required super.processRunner,
  });

  @override
  String get name => 'install';

  @override
  String get description => 'Install Apple provisioning profiles.';

  @override
  CommandConfig<AppleProvisioningProfileInstallConfigData> getConfig() =>
      AppleProvisioningProfileInstallCommandConfig();

  @override
  Future<void> runCommand(
      AppleProvisioningProfileInstallConfigData configData) async {
    final plugin = AppleProvisioningProfilePlugin(processRunner: processRunner);
    await plugin.scanAndInstallProvisioningProfiles();
  }
}
