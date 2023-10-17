import 'package:args/args.dart';
import 'package:impaktfull_cli/src/command/cli_command.dart';
import 'package:impaktfull_cli/src/model/error/impaktfull_cli_argument_error.dart';
import 'package:impaktfull_cli/src/util/args/cli/cli_arguments.dart';
import 'package:impaktfull_cli/src/util/extensions/arg_parser_extensions.dart';
import 'package:impaktfull_cli/src/util/extensions/args_extensions.dart';
import 'package:impaktfull_cli/src/util/extensions/iterable_extensions.dart';
import 'package:impaktfull_cli/src/util/logger/logger.dart';

class CliArgumentsParser {
  final List<CliCommand<dynamic>> commands;

  const CliArgumentsParser({
    required this.commands,
  });

  CliArguments parse(List<String> args) {
    final argParser = _initArgParser();
    try {
      final result = argParser.parse(args);
      return _processResult(result, argParser);
    } catch (error) {
      if (args.isEmpty) {
        throw ImpaktfullCliArgumentError('No command found',
            argParser: argParser, commands: commands);
      }
      final commandName = args.first;
      if (commands.any((e) => e.name == commandName)) {
        throw ImpaktfullCliArgumentError(error.toString(),
            argParser: argParser, commandName: commandName);
      } else {
        throw ImpaktfullCliArgumentError(
            '`$commandName` is not a valid command',
            argParser: argParser,
            commands: commands);
      }
    }
  }

  ArgParser _initArgParser() {
    final argParser = ArgParser();
    argParser.addGlobalFlags();
    for (final command in commands) {
      argParser.addCommand(command.name, command.argParser);
    }
    return argParser;
  }

  CliArguments _processResult(ArgResults result, ArgParser argParser) {
    final resultCommand = result.command;
    ImpaktfullCliLogger.init(
        isVerboseLoggingEnabled: result.isVerboseLoggingEnabled());
    final cliCommand = resultCommand == null
        ? null
        : commands.find((element) => element.name == resultCommand.name);
    if (cliCommand == null || resultCommand == null) {
      throw ImpaktfullCliArgumentError('No command found',
          argParser: argParser, commands: commands);
    }
    return CliArguments(
      cliCommand: cliCommand,
      argResults: resultCommand,
      originalArgParser: argParser,
    );
  }
}
