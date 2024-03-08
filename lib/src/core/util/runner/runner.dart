import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:impaktfull_cli/src/core/model/error/force_quit_error.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_argument_error.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/core/util/args/env/impaktfull_cli_environment.dart';
import 'package:impaktfull_cli/src/core/util/extensions/duration_extensions.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';

Future<void> runImpaktfullCli(
  Future<void> Function() run,
) async {
  try {
    final stopwatch = Stopwatch();
    stopwatch.start();
    await ImpaktfullCliEnvironment.init();
    await run();
    stopwatch.stop();
    ImpaktfullCliLogger.log(
        '✅ Success (You just saved ${stopwatch.elapsed.humanReadibleDuration})');
  } on UsageException catch (e) {
    ImpaktfullCliLogger.error(e.toString());
    exit(64); // Exit code 64 means a usage error occurred.
  } on ImpaktfullCliArgumentError catch (error) {
    ImpaktfullCliLogger.error(error.toString());
    exit(-1);
  } on ImpaktfullCliError catch (error) {
    ImpaktfullCliLogger.error(error.message);
    exit(-1);
  } on ForceQuitError catch (_) {
    // Ignore because `ForceQuitUtil` already cleaned up the process.
  }
}
