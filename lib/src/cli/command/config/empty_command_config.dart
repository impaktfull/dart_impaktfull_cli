import 'package:args/args.dart';
import 'package:impaktfull_cli/src/cli/command/config/command_config.dart';

class EmptyommandConfig extends CommandConfig<EmptyCommandConfigData> {
  @override
  void addConfig(ArgParser argParser) {}

  @override
  EmptyCommandConfigData parseResult(ArgResults? argResults) =>
      EmptyCommandConfigData();
}

class EmptyCommandConfigData extends ConfigData {}
