import 'package:args/command_runner.dart';
import 'package:impaktfull_cli/src/apple_certificate/command/apple_certificate_root_command.dart';
import 'package:impaktfull_cli/src/cli/util/extensions/arg_parser_extensions.dart';
import 'package:impaktfull_cli/src/cli/util/extensions/arg_result_extensions.dart';
import 'package:impaktfull_cli/src/cli/util/logger/logger.dart';
import 'package:impaktfull_cli/src/cli/util/process/process_runner.dart';
import 'package:impaktfull_cli/src/cli/util/runner/runner.dart';

class ImpaktfullCli {
  final ProcessRunner processRunner;

  ImpaktfullCli({
    required this.processRunner,
  });

  List<Command<dynamic>> getCommands() => [
        AppleCertificateRootCommand(processRunner: processRunner),
      ];

  Future<void> run(List<String> args) async {
    await runImpaktfullCli(() async {
      final runner = CommandRunner('impaktfull_cli',
          'A cli that replaces `fastlane` by simplifying the CI/CD process.');
      runner.argParser.addGlobalFlags();

      for (final command in getCommands()) {
        runner.addCommand(command);
      }
      final argResults = runner.argParser.parse(args);
      CliLogger.init(
          isVerboseLoggingEnabled: argResults.isVerboseLoggingEnabled());
      await runner.run(args);
    });
  }
}
