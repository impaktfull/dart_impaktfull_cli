import 'package:impaktfull_cli/src/cli/command/command/impaktfull_command.dart';
import 'package:impaktfull_cli/src/cli/command/config/command_config.dart';
import 'package:impaktfull_cli/src/cli/util/process/process_runner.dart';

abstract class CliCommand<T extends ConfigData> extends ImpaktfullCommand<T> {
  final ProcessRunner processRunner;

  CliCommand({
    required this.processRunner,
  });
}
