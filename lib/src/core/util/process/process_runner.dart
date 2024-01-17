import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:impaktfull_cli/src/core/model/error/force_quit_error.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';

abstract class ProcessRunner {
  const ProcessRunner();

  Future<String> runProcess(
    List<String> args, {
    Map<String, String>? environment,
  });
}

class CliProcessRunner extends ProcessRunner {
  const CliProcessRunner();

  @override
  Future<String> runProcess(
    List<String> args, {
    Map<String, String>? environment,
  }) async {
    final fullCommand = args.join(' ');
    ImpaktfullCliLogger.verboseSeperator();
    ImpaktfullCliLogger.verbose(fullCommand);
    ImpaktfullCliLogger.verboseSeperator();
    final result = await Process.start(
      args.first,
      args.length > 1 ? args.sublist(1) : [],
      environment: environment,
    );
    final stringBuffer = StringBuffer();
    final subscriptionOut = result.stdout.listen((codeUnits) {
      final line = utf8.decode(codeUnits);
      stringBuffer.writeln(line);
      ImpaktfullCliLogger.verbose(line);
    });
    final subscriptionError = result.stderr.listen((codeUnits) {
      final line = utf8.decode(codeUnits);
      stringBuffer.writeln(line);
      ImpaktfullCliLogger.verbose(line);
    });
    final exitCode = await result.exitCode;
    ImpaktfullCliLogger.verboseSeperator();
    if (exitCode == -2) {
      throw ForceQuitError('`$fullCommand` was force quit');
    }
    if (exitCode != 0) {
      throw ImpaktfullCliError('`$fullCommand` exited with code $exitCode');
    }
    await subscriptionOut.cancel();
    await subscriptionError.cancel();
    return stringBuffer.toString().trim();
  }
}
