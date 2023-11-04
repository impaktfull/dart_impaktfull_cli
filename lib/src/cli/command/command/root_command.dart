import 'package:args/command_runner.dart';
import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/cli/command/command/cli_command.dart';
import 'package:impaktfull_cli/src/cli/command/config/empty_command_config.dart';
import 'package:meta/meta.dart';

abstract class RootCommand extends CliCommand<EmptyCommandConfigData> {
  RootCommand({
    required super.processRunner,
  }) {
    for (final subCommand in getSubCommands()) {
      addSubcommand(subCommand);
    }
  }

  List<Command<void>> getSubCommands();

  @nonVirtual
  @override
  EmptyommandConfig getConfig() => EmptyommandConfig();

  @nonVirtual
  @override
  Future<void> runCommand(EmptyCommandConfigData configData) async {
    CliLogger.error('`$name` is a root command, you can not run it by itself');
  }
}
