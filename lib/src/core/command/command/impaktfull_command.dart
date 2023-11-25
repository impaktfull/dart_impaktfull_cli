import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_argument_error.dart';

abstract class ImpaktfullCommand<T extends ConfigData> extends Command<void> {
  ImpaktfullCommand() {
    getConfig().addConfig(argParser);
  }

  CommandConfig<T> getConfig();

  @override
  FutureOr<void>? run() async {
    T configData;
    try {
      configData = getConfig().parseResult(argResults);
    } on ArgumentError catch (e) {
      throw ImpaktfullCliArgumentError(
        e.message.toString(),
        argResults?.name,
        argParser.usage,
      );
    }
    await runCommand(configData);
  }

  Future<void> runCommand(T configData);
}
