import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:impaktfull_cli/src/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/util/logger/logger.dart';

abstract class ProcessRunner {
  const ProcessRunner();

  Future<String> runProcess(
    List<String> args,
  );

  Future<void> runProcessVerbose(
    List<String> args, [
    void Function(String lines)? onLineWrite,
  ]);
}

class CliProcessRunner extends ProcessRunner {
  const CliProcessRunner();

  @override
  Future<String> runProcess(
    List<String> args,
  ) async {
    final fullCommand = args.join(' ');
    ImpaktfullCliLogger.verbose(fullCommand);
    final result = await Process.run(
      args.first,
      args.length > 1 ? args.sublist(1) : [],
    );
    final error = result.stderr.toString();
    if (error.isNotEmpty) {
      throw ImpaktfullCliError(error);
    }
    return result.stdout.toString();
  }

  @override
  Future<void> runProcessVerbose(
    List<String> args, [
    void Function(String lines)? onLineWrite,
  ]) async {
    final fullCommand = args.join(' ');
    ImpaktfullCliLogger.verbose(fullCommand);
    final completer = Completer<void>();
    final result = await Process.start(
      args.first,
      args.length > 1 ? args.sublist(1) : [],
      mode: ProcessStartMode.detachedWithStdio,
    );
    ImpaktfullCliLogger.verbose(
        '======================================================================');
    final subscription = result.stdout.listen((codeUnits) {
      final line = utf8.decode(codeUnits);
      onLineWrite?.call(line);
      stdout.write(line);
    });
    subscription.onDone(() {
      ImpaktfullCliLogger.verbose(
          '======================================================================');
      completer.complete();
      subscription.cancel();
    });
    subscription.onError((dynamic error) =>
        completer.completeError('Failed to complete `$fullCommand`: $error'));
    return completer.future;
  }
}
