import 'package:impaktfull_cli/src/command/apple_certificate/install/install_apple_certificate_command.dart';
import 'package:impaktfull_cli/src/command/apple_certificate/remove/remove_apple_certificate_command.dart';
import 'package:impaktfull_cli/src/command/cli_command.dart';
import 'package:impaktfull_cli/src/command/help/help_command.dart';
import 'package:impaktfull_cli/src/util/args/cli/cli_args_parser.dart';
import 'package:impaktfull_cli/src/util/runner/runner.dart';

class ImpaktfullCli {
  static const List<CliCommand<dynamic>> defaultCommands = [
    InstallAppleCertificateCommand(),
    RemoveAppleCertificateCommand(),
    HelpCommand(),
  ];
  final CliArgumentsParser cliArgsParser;

  const ImpaktfullCli({
    this.cliArgsParser = const CliArgumentsParser(commands: defaultCommands),
  });

  Future<void> run(List<String> args) async {
    await runImpaktfullCli(() async {
      final cliArgs = cliArgsParser.parse(args);
      await cliArgs.cliCommand
          .run(cliArgs.originalArgParser, cliArgs.argResults);
    });
  }
}
