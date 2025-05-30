import 'package:args/args.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/integrations/apple/provisioning_profile/model/remove/apple_provisioning_profile_remove_config_data.dart';

class AppleProvisioningProfileRemoveCommandConfig
    extends CommandConfig<AppleProvisioningProfileRemoveConfigData> {
  AppleProvisioningProfileRemoveCommandConfig();
  @override
  void addConfig(ArgParser argParser) {}

  @override
  AppleProvisioningProfileRemoveConfigData parseResult(
          ArgResults? argResults) =>
      AppleProvisioningProfileRemoveConfigData();
}
