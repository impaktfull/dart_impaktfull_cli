import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/util/extensions/duration_extensions.dart';

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
  } on ImpaktfullCliError catch (error, trace) {
    ImpaktfullCliLogger.error(error.message);
    await onError?.call(error, trace);
    exit(-1);
  } on ImpaktfullCliArgumentError catch (error, trace) {
    ImpaktfullCliLogger.argumentError(
      error.message,
      argParser: error.argParser,
      commands: error.commands,
      commandName: error.commandName,
    );
    await onError?.call(error, trace);
    exit(-1);
  } catch (error, trace) {
    if (onError == null) rethrow;
    await onError.call(error, trace);
  }
}
