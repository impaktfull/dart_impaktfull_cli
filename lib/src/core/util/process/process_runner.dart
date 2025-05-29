import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:impaktfull_cli/src/core/model/error/force_quit_error.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/core/util/args/env/impaktfull_cli_environment_variables.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';

final _pathsToAdd = <String>[];
String? _path;

abstract class ProcessRunner {
  const ProcessRunner();

  Future<String> runProcess(
    List<String> args, {
    Map<String, String>? environment,
    bool runInShell = false,
    ProcessStartMode mode = ProcessStartMode.normal,
  });

  Future<void> requestSudo();

  static void updatePath({required List<String> pathsToAdd}) {
    _pathsToAdd.addAll(pathsToAdd);
    final pathEnvVariable =
        ImpaktfullCliEnvironmentVariables.getEnvVariable("PATH");
    final home = ImpaktfullCliEnvironmentVariables.getEnvVariable("HOME");
    final sb = StringBuffer(pathEnvVariable);
    for (final path in _pathsToAdd) {
      final cleanPath = path.replaceAll('\$HOME', home);
      if (sb.isEmpty) {
        sb.write(cleanPath);
      } else {
        sb.write(':$cleanPath');
      }
    }
    _path = sb.toString();
  }
}

class CliProcessRunner extends ProcessRunner {
  const CliProcessRunner();

  @override
  Future<String> runProcess(
    List<String> args, {
    Map<String, String>? environment,
    bool runInShell = false,
    ProcessStartMode mode = ProcessStartMode.normal,
  }) async {
    final fullCommand = args.join(' ');
    ImpaktfullCliLogger.verboseSeperator();
    ImpaktfullCliLogger.verbose(fullCommand);
    if (_path != null) {
      ImpaktfullCliLogger.verbose("PATH: $_path");
    }
    ImpaktfullCliLogger.verboseSeperator();
    final result = await Process.start(
      args.first,
      args.length > 1 ? args.sublist(1) : [],
      environment: {
        ...?environment,
        if (_path != null) 'PATH': _path!,
      },
      runInShell: runInShell,
      mode: mode,
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

  @override
  Future<void> requestSudo() async {
    ImpaktfullCliLogger.stopSpinner();
    ImpaktfullCliLogger.log("Enter your sudo password to continue:");
    final sudoProcess = await Process.start(
      'sudo',
      ['-v'],
      mode: ProcessStartMode.inheritStdio,
      runInShell: true,
    );

    final sudoExit = await sudoProcess.exitCode;
    if (sudoExit != 0) {
      throw ImpaktfullCliError('Sudo authorization failed.');
    }
    ImpaktfullCliLogger.continueSpinner();
  }
}
