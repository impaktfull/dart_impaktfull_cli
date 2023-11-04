import 'package:args/command_runner.dart';
import 'package:impaktfull_cli/src/apple_certificate/command/install/apple_certificate_install_command.dart';
import 'package:impaktfull_cli/src/apple_certificate/command/remove/apple_certificate_remove_command.dart';
import 'package:impaktfull_cli/src/cli/command/command/root_command.dart';

class AppleCertificateRootCommand extends RootCommand {
  @override
  String get name => 'apple_certificate';

  @override
  String get description => 'Build the app-in-app artifacts.';

  AppleCertificateRootCommand({
    required super.processRunner,
  });

  @override
  List<Command<dynamic>> getSubCommands() {
    final util = AppleCertificateUtil();
    return [
      AppleCertificateInstallCommand(
        processRunner: processRunner,
        util: util,
      ),
      AppleCertificateRemoveCommand(
        processRunner: processRunner,
        util: util,
      ),
    ];
  }
}

class AppleCertificateUtil {
  final defaultKeyChainName = 'ImpaktfullCliKeyChain';
}
