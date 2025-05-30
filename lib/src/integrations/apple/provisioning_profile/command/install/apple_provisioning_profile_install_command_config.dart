import 'package:args/args.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/integrations/apple/provisioning_profile/model/install/apple_provisioning_profile_install_config_data.dart';

class AppleProvisioningProfileInstallCommandConfig
    extends CommandConfig<AppleProvisioningProfileInstallConfigData> {
  const AppleProvisioningProfileInstallCommandConfig();

  @override
  void addConfig(ArgParser argParser) {}

  @override
  AppleProvisioningProfileInstallConfigData parseResult(
          ArgResults? argResults) =>
      AppleProvisioningProfileInstallConfigData();
}
