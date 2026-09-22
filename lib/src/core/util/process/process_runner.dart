import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:impaktfull_cli/src/core/model/error/force_quit_error.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_process_runner_error.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';
import 'package:meta/meta.dart';

final _pathsToAdd = <String>[];
String? _path;

abstract class ProcessRunner {
  const ProcessRunner();

  Future<String> runProcess(
    List<String> args, {
    Map<String, String>? environment,
    bool runInShell = false,
    ProcessStartMode mode = ProcessStartMode.normal,
    bool maskOutput = false,
    bool maskErrorOutput = false,
  });

  Future<void> requestSudo();

  static void updatePath({required List<String> pathsToAdd}) {
    _pathsToAdd.addAll(pathsToAdd);
    final environment = Platform.environment;
    _path = buildPath(
      currentPath: environment[_pathKey],
      // Windows has no HOME, only USERPROFILE.
      home: environment['HOME'] ?? environment['USERPROFILE'],
      pathsToAdd: _pathsToAdd,
      isWindows: Platform.isWindows,
    );
  }

  @visibleForTesting
  static String buildPath({
    required String? currentPath,
    required String? home,
    required List<String> pathsToAdd,
    required bool isWindows,
  }) {
    final separator = isWindows ? ';' : ':';
    return [
      if (currentPath != null && currentPath.isNotEmpty) currentPath,
      for (final path in pathsToAdd)
        home == null ? path : path.replaceAll('\$HOME', home),
    ].join(separator);
  }
}

/// The name of the PATH variable as the parent process spells it.
///
/// Windows spells it `Path`. A child environment that contains both `Path`
/// (inherited) and `PATH` (ours) has two entries, and which one wins is
/// undefined, so ours has to override the inherited key itself.
String get _pathKey => Platform.environment.keys.firstWhere(
      (key) => key.toUpperCase() == 'PATH',
      orElse: () => 'PATH',
    );

DateTime? _lastRequestSudoTime;

class CliProcessRunner extends ProcessRunner {
  const CliProcessRunner();

  @override
  Future<String> runProcess(
    List<String> args, {
    Map<String, String>? environment,
    bool runInShell = false,
    ProcessStartMode mode = ProcessStartMode.normal,
    bool maskOutput = false,
    bool maskErrorOutput = false,
  }) async {
    if (args.isNotEmpty && args.first == "sudo") {
      await _checkIfSudoQuestionIsRequiredAgain();
    }
    final fullCommand = args.join(' ');
    ImpaktfullCliLogger.verboseSeperator();
    ImpaktfullCliLogger.verbose(fullCommand);
    if (_path != null) {
      ImpaktfullCliLogger.verbose("PATH: $_path");
    }
    ImpaktfullCliLogger.verboseSeperator();
    final process = await Process.start(
      args.first,
      args.length > 1 ? args.sublist(1) : [],
      environment: {
        ...?environment,
        if (_path != null) _pathKey: _path!,
      },
      // On Windows `flutter`, `fvm` and friends are `.bat` files, which only
      // start through the shell. The shell also looks the executable up in
      // the PATH we pass, instead of the PATH of this process.
      runInShell: runInShell || Platform.isWindows,
      mode: mode,
    );
    final stringBuffer = StringBuffer();
    // Decode the stream instead of every chunk on its own: a chunk can end in
    // the middle of a multi-byte character or a line.
    Future<void> collect(Stream<List<int>> stream, {required bool mask}) =>
        stream
            .transform(const Utf8Decoder(allowMalformed: true))
            .transform(const LineSplitter())
            .forEach((line) {
          stringBuffer.writeln(line);
          ImpaktfullCliLogger.verboseMasked(line, mask: mask);
        });

    // The exit code can complete before all output is delivered. Waiting on
    // the streams as well makes sure none of the output is lost, which used
    // to make `which flutter` randomly return nothing.
    final (exitCode, _, _) = await (
      process.exitCode,
      collect(process.stdout, mask: maskOutput),
      collect(process.stderr, mask: maskErrorOutput),
    ).wait;
    ImpaktfullCliLogger.verboseSeperator();
    if (exitCode == -2) {
      throw ForceQuitError('`$fullCommand` was force quit');
    }
    final fullOutput = stringBuffer.toString().trim();
    if (exitCode != 0) {
      throw ImpaktfullCliProcessRunnerError(
        '`$fullCommand` exited with code $exitCode',
        fullOutput,
      );
    }
    return fullOutput;
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
    _lastRequestSudoTime = DateTime.now();

    final sudoExit = await sudoProcess.exitCode;
    if (sudoExit != 0) {
      throw ImpaktfullCliError('Sudo authorization failed.');
    }
    ImpaktfullCliLogger.continueSpinner();
  }

  Future<void> _checkIfSudoQuestionIsRequiredAgain() async {
    final lastRequestSudoTime = _lastRequestSudoTime;
    if (lastRequestSudoTime != null) {
      final now = DateTime.now();
      final diff = now.difference(lastRequestSudoTime);
      // less than 5 minutes since last sudo request
      if (diff.inSeconds < 300) {
        return;
      }
    }
    await requestSudo();
  }
}
