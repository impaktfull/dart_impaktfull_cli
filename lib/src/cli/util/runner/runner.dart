import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/cli/model/error/impaktfull_cli_argument_error.dart';
import 'package:impaktfull_cli/src/cli/util/extensions/duration_extensions.dart';

Future<void> runImpaktfullCli(
  Future<void> Function() run, {
  bool isVerboseLoggingEnabled = false,
  Future<void> Function(Object error, StackTrace trace)? onError,
}) async {
  try {
    final stopwatch = Stopwatch();
    stopwatch.start();
    await ImpaktfullCliEnvironment.init(
        isVerboseLoggingEnabled: isVerboseLoggingEnabled);
    await run();
    stopwatch.stop();
    CliLogger.log(
        '✅ Success (You just saved ${stopwatch.elapsed.humanReadibleDuration})');
  } on UsageException catch (e) {
    CliLogger.error(e.toString());
    exit(64); // Exit code 64 means a usage error occurred.
  } on ImpaktfullCliArgumentError catch (error, trace) {
    CliLogger.error(error.toString());
    await onError?.call(error, trace);
    exit(-1);
  } on ImpaktfullCliError catch (error, trace) {
    CliLogger.error(error.message);
    await onError?.call(error, trace);
    exit(-1);
  } catch (error, trace) {
    if (onError == null) rethrow;
    await onError.call(error, trace);
  }
}
