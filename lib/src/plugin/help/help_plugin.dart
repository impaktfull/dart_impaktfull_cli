import 'package:args/args.dart';
import 'package:impaktfull_cli/src/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/plugin/impaktfull_plugin.dart';
import 'package:impaktfull_cli/src/util/logger/logger.dart';

class HelpPlugin extends ImpaktfullPlugin {
  const HelpPlugin();

  void printHelp(ArgParser parser) => ImpaktfullCliLogger.argumentError('',
      argParser: parser, commands: ImpaktfullCli.defaultCommands);
}
