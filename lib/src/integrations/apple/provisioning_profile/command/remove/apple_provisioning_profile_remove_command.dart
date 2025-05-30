import 'package:impaktfull_cli/src/core/command/command/cli_command.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/integrations/apple/provisioning_profile/command/remove/apple_provisioning_profile_remove_command_config.dart';
import 'package:impaktfull_cli/src/integrations/apple/provisioning_profile/model/remove/apple_provisioning_profile_remove_config_data.dart';

class AppleProvisioningProfileRemoveCommand
    extends CliCommand<AppleProvisioningProfileRemoveConfigData> {
  AppleProvisioningProfileRemoveCommand({
    required super.processRunner,
  });

  @override
  String get name => 'remove';

  @override
  String get description => 'Remove Apple provisioning profiles';

  @override
  CommandConfig<AppleProvisioningProfileRemoveConfigData> getConfig() =>
      AppleProvisioningProfileRemoveCommandConfig();

  @override
  Future<void> runCommand(
      AppleProvisioningProfileRemoveConfigData configData) async {}
}
