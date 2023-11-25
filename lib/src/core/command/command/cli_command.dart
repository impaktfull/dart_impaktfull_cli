import 'package:impaktfull_cli/src/core/command/command/impaktfull_command.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/core/util/process/process_runner.dart';

abstract class CliCommand<T extends ConfigData> extends ImpaktfullCommand<T> {
  final ProcessRunner processRunner;

  CliCommand({
    required this.processRunner,
  });
}
