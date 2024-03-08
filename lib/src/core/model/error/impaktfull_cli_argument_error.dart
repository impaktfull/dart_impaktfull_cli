import 'package:args/args.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';

class ImpaktfullCliArgumentError extends ImpaktfullCliError {
  final ArgParser argParser;

  ImpaktfullCliArgumentError(
    super.message, {
    required this.argParser,
  });
}
