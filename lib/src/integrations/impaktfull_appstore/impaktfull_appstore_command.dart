import 'package:args/command_runner.dart';
import 'package:impaktfull_cli/src/core/command/command/root_command.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_appstore/command/upload/command/impaktfull_appstore_upload_command.dart';

class ImpaktfullAppstoreRootCommand extends RootCommand {
  @override
  String get name => 'appstore';

  @override
  String get description => 'Commands for the impaktfull appstore.';

  ImpaktfullAppstoreRootCommand({
    required super.processRunner,
  });

  @override
  List<Command<dynamic>> getSubCommands() {
    return [
      ImpaktfullAppstoreUploadCommand(processRunner: processRunner),
    ];
  }
}
