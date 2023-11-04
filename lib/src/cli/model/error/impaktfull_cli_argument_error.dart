import 'package:impaktfull_cli/impaktfull_cli.dart';

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
