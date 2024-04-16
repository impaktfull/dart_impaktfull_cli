import 'package:args/command_runner.dart';
import 'package:impaktfull_cli/src/integrations/android/create_keystore/command/create_keystore/android_create_keystore_command.dart';
import 'package:impaktfull_cli/src/core/command/command/root_command.dart';

class AndroidRootCommand extends RootCommand {
  @override
  String get name => 'android';

  @override
  String get description => 'Commands for Android integrations.';

  AndroidRootCommand({
    required super.processRunner,
  });

  @override
  List<Command<dynamic>> getSubCommands() {
    return [
      AndroidCreateKeystoreCommand(processRunner: processRunner),
    ];
  }
}
