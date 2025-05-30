import 'package:args/command_runner.dart';
import 'package:impaktfull_cli/src/core/command/command/root_command.dart';
import 'package:impaktfull_cli/src/integrations/apple/provisioning_profile/command/install/apple_provisioning_profile_install_command.dart';
import 'package:impaktfull_cli/src/integrations/apple/provisioning_profile/command/remove/apple_provisioning_profile_remove_command.dart';

class AppleProvisioningProfileRootCommand extends RootCommand {
  @override
  String get name => 'provisioning_profile';

  @override
  String get description => 'Configure Apple provisioning profiles.';

  AppleProvisioningProfileRootCommand({
    required super.processRunner,
  });

  @override
  List<Command<dynamic>> getSubCommands() {
    return [
      AppleProvisioningProfileInstallCommand(
        processRunner: processRunner,
      ),
      AppleProvisioningProfileRemoveCommand(
        processRunner: processRunner,
      ),
    ];
  }
}
