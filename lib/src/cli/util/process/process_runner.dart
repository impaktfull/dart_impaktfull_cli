import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:impaktfull_cli/src/cli/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/cli/util/logger/logger.dart';

abstract class ProcessRunner {
  const ProcessRunner();

  Future<String> runProcess(
    List<String> args,
  );

  Future<String> runProcessVerbose(List<String> args);
}

class CliProcessRunner extends ProcessRunner {
  const CliProcessRunner();

  @override
  Future<String> runProcess(
    List<String> args,
  ) async {
    final fullCommand = args.join(' ');
    CliLogger.verbose(fullCommand);
    final result = await Process.run(
      args.first,
      args.length > 1 ? args.sublist(1) : [],
    );
    final error = result.stderr.toString();
    if (error.isNotEmpty) {
      throw ImpaktfullCliError(error);
    }
    return result.stdout.toString().trim();
  }

  @override
  Future<String> runProcessVerbose(List<String> args) async {
    final fullCommand = args.join(' ');
    CliLogger.verbose(fullCommand);
    final completer = Completer<String>();
    final result = await Process.start(
      args.first,
      args.length > 1 ? args.sublist(1) : [],
      mode: ProcessStartMode.detachedWithStdio,
    );
    final stringBuffer = StringBuffer();
    CliLogger.verboseSeperator();
    final subscriptionOut = result.stdout.listen((codeUnits) {
      final line = utf8.decode(codeUnits);
      stringBuffer.writeln(line);
      stdout.write(line);
    });
    final subscriptionError = result.stderr.listen((codeUnits) {
      final line = utf8.decode(codeUnits);
      stringBuffer.writeln(line);
      stderr.write('Error: $line');
    });

    subscriptionOut.onDone(() async {
      CliLogger.verboseSeperator();
      await subscriptionOut.cancel();
      await subscriptionError.cancel();
      if (exitCode == 0) {
        completer.complete(stringBuffer.toString());
      } else {
        completer.completeError('Failed to complete `$fullCommand`');
      }
    });
    subscriptionError.onDone(() async {
      CliLogger.verboseSeperator();
      await subscriptionOut.cancel();
      await subscriptionError.cancel();
      if (exitCode == 0) {
        completer.complete(stringBuffer.toString());
      } else {
        completer.completeError('Failed to complete `$fullCommand`');
      }
    });
    return completer.future;
  }
}
