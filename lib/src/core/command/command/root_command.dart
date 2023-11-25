import 'package:args/command_runner.dart';
import 'package:impaktfull_cli/src/core/command/command/cli_command.dart';
import 'package:impaktfull_cli/src/core/command/config/empty_command_config.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';
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
  EmptyCommandConfig getConfig() => EmptyCommandConfig();

  @nonVirtual
  @override
  Future<void> runCommand(EmptyCommandConfigData configData) async {
    ImpaktfullCliLogger.error(
        '`$name` is a root command, you can not run it by itself');
  }
}
