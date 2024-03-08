import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';

class ImpaktfullCliProcessRunnerError extends ImpaktfullCliError {
  final String errorOutput;

  ImpaktfullCliProcessRunnerError(
    super.message,
    this.errorOutput,
  );
}
