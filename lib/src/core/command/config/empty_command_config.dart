import 'package:args/args.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';

class EmptyCommandConfig extends CommandConfig<EmptyCommandConfigData> {
  @override
  void addConfig(ArgParser argParser) {}

  @override
  EmptyCommandConfigData parseResult(ArgResults? argResults) =>
      EmptyCommandConfigData();
}

class EmptyCommandConfigData extends ConfigData {}
