import 'package:args/args.dart';
import 'package:impaktfull_cli/src/command/cli_command.dart';

class ImpaktfullCliArgumentError extends Error {
  final String message;
  final ArgParser argParser;
  final List<CliCommand<dynamic>> commands;
  final String? commandName;

  ImpaktfullCliArgumentError(
    this.message, {
    required this.argParser,
    this.commands = const [],
    this.commandName,
  });
}
