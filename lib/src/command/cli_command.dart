import 'package:args/args.dart';
import 'package:impaktfull_cli/src/model/error/impaktfull_cli_argument_error.dart';
import 'package:impaktfull_cli/src/util/extensions/arg_parser_extensions.dart';

abstract class CliCommand<T> {
  String get name;

  ArgParser get argParser;

  const CliCommand();

  Future<void> run(ArgParser originalArgParser, ArgResults args) async {
    try {
      final argumentsWithoutGlobalFlags = List.of(args.arguments);
      argumentsWithoutGlobalFlags
          .remove('--${ArgsParserExtension.verboseFlag}');
      argumentsWithoutGlobalFlags
          .remove('-${ArgsParserExtension.verboseFlag[0]}');
      final result = argParser.parse(argumentsWithoutGlobalFlags);
      final params = await convertToParams(originalArgParser, result);
      await runCommand(params);
    } catch (e) {
      throw ImpaktfullCliArgumentError(e.toString(),
          argParser: argParser, commandName: name);
    }
  }

  Future<T> convertToParams(ArgParser originalArgParser, ArgResults results);

  Future<void> runCommand(T params);
}
