import 'package:args/args.dart';

abstract class CommandConfig<T extends ConfigData> {
  const CommandConfig();

  T parseResult(ArgResults? argResults);

  void addConfig(ArgParser argParser);
}

abstract class ConfigData {
  const ConfigData();
}
