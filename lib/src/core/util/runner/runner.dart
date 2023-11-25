import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_argument_error.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/core/util/args/env/impaktfull_cli_environment.dart';
import 'package:impaktfull_cli/src/core/util/extensions/duration_extensions.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';

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
    ImpaktfullCliLogger.log(
        '✅ Success (You just saved ${stopwatch.elapsed.humanReadibleDuration})');
  } on UsageException catch (e) {
    ImpaktfullCliLogger.error(e.toString());
    exit(64); // Exit code 64 means a usage error occurred.
  } on ImpaktfullCliArgumentError catch (error, trace) {
    ImpaktfullCliLogger.error(error.toString());
    await onError?.call(error, trace);
    exit(-1);
  } on ImpaktfullCliError catch (error, trace) {
    ImpaktfullCliLogger.error(error.message);
    await onError?.call(error, trace);
    exit(-1);
  } catch (error, trace) {
    if (onError == null) rethrow;
    await onError.call(error, trace);
  }
}
