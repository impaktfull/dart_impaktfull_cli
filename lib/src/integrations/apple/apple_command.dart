import 'package:args/command_runner.dart';
import 'package:impaktfull_cli/src/core/command/command/root_command.dart';
import 'package:impaktfull_cli/src/integrations/apple/apple_certificate/command/apple_certificate_root_command.dart';

class AppleRootCommand extends RootCommand {
  @override
  String get name => 'apple';

  @override
  String get description => 'Commands for Apple integrations.';

  AppleRootCommand({
    required super.processRunner,
  });

  @override
  List<Command<dynamic>> getSubCommands() {
    return [
      AppleCertificateRootCommand(processRunner: processRunner),
    ];
  }
}
