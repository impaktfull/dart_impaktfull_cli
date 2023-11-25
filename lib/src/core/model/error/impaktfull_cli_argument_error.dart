import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';

class ImpaktfullCliArgumentError extends ImpaktfullCliError {
  final String? command;
  final String usage;

  ImpaktfullCliArgumentError(
    super.message,
    this.command,
    this.usage,
  );

  @override
  String toString() => '''Error while parsing arguments for `$command`:

$message

Usage fo `$command`:
$usage
''';
}
