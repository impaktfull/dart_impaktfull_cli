import 'package:args/args.dart';
import 'package:impaktfull_cli/src/command/cli_command.dart';

class CliArguments {
  final CliCommand<dynamic> cliCommand;
  final ArgResults argResults;
  final ArgParser originalArgParser;

  const CliArguments({
    required this.cliCommand,
    required this.argResults,
    required this.originalArgParser,
  });
}
