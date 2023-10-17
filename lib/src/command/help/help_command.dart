import 'package:args/args.dart';
import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/command/cli_command.dart';

class HelpCommand extends CliCommand<ArgParser> {
  const HelpCommand();

  @override
  String get name => 'help';

  @override
  ArgParser get argParser => ArgParser();

  @override
  Future<ArgParser> convertToParams(
          ArgParser originalArgParser, ArgResults results) async =>
      originalArgParser;

  @override
  Future<void> runCommand(ArgParser params) async {
    HelpPlugin().printHelp(params);
  }
}
