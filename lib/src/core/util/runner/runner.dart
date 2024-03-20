import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:impaktfull_cli/src/core/model/error/force_quit_error.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_exit_error.dart';
import 'package:impaktfull_cli/src/core/util/args/env/impaktfull_cli_environment.dart';
import 'package:impaktfull_cli/src/core/util/extensions/duration_extensions.dart';
import 'package:impaktfull_cli/src/core/util/input_listener/versbose_logging_listener.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';

Future<void> runImpaktfullCli(
  Future<void> Function() run,
) async {
  try {
    VerboseLoggingListener.startInputListener();
    final stopwatch = Stopwatch();
    stopwatch.start();
    await ImpaktfullCliEnvironment.init();
    await run();
    stopwatch.stop();
    VerboseLoggingListener.stopListening();
    ImpaktfullCliLogger.endSpinner();
    ImpaktfullCliLogger.log(
        '✅ Success (You just saved ${stopwatch.elapsed.humanReadibleDuration})');
  } on ImpaktfullCliExitError catch (e, trace) {
    ImpaktfullCliLogger.failSpinner(e, trace);
    exit(0);
  } on UsageException catch (e, trace) {
    ImpaktfullCliLogger.failSpinner(e, trace);
    exit(64); // Exit code 64 indicates a usage error.
  } on ForceQuitError catch (_) {
    // Ignore because `ForceQuitUtil` already cleaned up the process.
  } catch (e, trace) {
    ImpaktfullCliLogger.failSpinner(e, trace);
    exit(1);
  }
}
