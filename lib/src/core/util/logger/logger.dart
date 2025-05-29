import 'dart:convert';
import 'dart:io';

import 'package:cli_spin/cli_spin.dart';
import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_exit_error.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_process_runner_error.dart';
import 'package:path/path.dart';

class ImpaktfullCliLogger {
  static late File _logFile;

  static final _secrets = <String>[];
  static bool _verbose = false;
  static final _pendingLogs = <String>[];
  static const String _seperator =
      '================================================================================';
  static const String _seperatorSingleLine =
      '--------------------------------------------------------------------------------';

  static String? _cliSpinnerActionDescription;
  static CliSpin? _cliSpinner;

  static String? _spinnerPrefix;

  static bool get isVerboseLoggingEnabled => _verbose;

  ImpaktfullCliLogger._();

  static void init() {
    _logFile = File(join(Directory.current.path, 'impaktfull_cli.log'));
  }

  static void enableVerbose({bool isVerboseLoggingEnabled = false}) {
    _verbose = isVerboseLoggingEnabled;
    if (isVerboseLoggingEnabled) {
      _cliSpinner?.stop();
      _printPendingLogs();
      ImpaktfullCliLogger.verbose('Verbose logging enabled');
    } else {
      _cliSpinner?.start();
    }
  }

  static void _printPendingLogs({bool toFile = false}) {
    final pendingLogs = List<String>.from(_pendingLogs);
    _pendingLogs.clear();
    if (pendingLogs.isNotEmpty) {
      if (toFile) {
        _logFile.createSync(recursive: true);
        _logFile.writeAsStringSync(pendingLogs.join('\n'));
      } else {
        for (final log in pendingLogs) {
          _print(log);
        }
      }
    }
  }

  static void log(String message) => _print(message);

  static void logSeperator({bool singleLine = false}) =>
      log(singleLine ? _seperatorSingleLine : _seperator);

  static void verboseSeperator({bool singleLine = false}) =>
      verbose(singleLine ? _seperatorSingleLine : _seperator);

  static void error(String message) {
    if (message.startsWith('[ERROR]')) {
      _print(message);
    } else {
      _print('[ERROR] $message');
    }
  }

  static void _logCliError(ImpaktfullCliError error) {
    final sb = StringBuffer();
    sb.writeln();
    sb.writeln(_seperator);
    if (error is ImpaktfullCliArgumentError) {
      sb.writeln('CliArgumentError:');
    } else {
      sb.writeln('Something went wrong:');
    }
    if (error is ImpaktfullCliProcessRunnerError) {
      final errorMessages = error.errorOutput
          .split('\n')
          .where((element) => element.contains('error:'));
      if (errorMessages.isNotEmpty) {
        sb.writeln();
        sb.writeln(
            'Possible logs we detected could be interesting to investigate:');
        sb.writeln();
        sb.writeln();
        for (final element in errorMessages) {
          sb.writeln(element);
        }
        sb.writeln();
        sb.writeln();
      }
    }
    sb.writeln(error.message);
    sb.writeln(_seperator);
    if (error is ImpaktfullCliArgumentError) {
      sb.writeln('Usage:');
      sb.writeln(error.argParser.usage);
    } else {
      sb.writeln(error.stackTrace);
    }
    log(sb.toString());
  }

  static void verbose(String message) {
    if (!_verbose) {
      _pendingLogs.add(message);
      return;
    }
    _print(message);
  }

  static void _print(String message) {
    var safeMessage = message;
    for (final secret in _secrets) {
      safeMessage = safeMessage.replaceAll(secret, '****');
    }
    print(safeMessage);
  }

  // Input
  static String? askQuestion(String title) {
    log('\n$title');
    return stdin.readLineSync(encoding: utf8);
  }

  static bool askYesNoQuestion(String title) {
    log('\n$title (y/n)');
    bool? result;
    do {
      var line = stdin.readLineSync(encoding: utf8);
      final allowedValues = ['y', 'n', 'yes', 'no'];
      if (allowedValues.contains(line)) {
        result = line == 'y' || line == 'yes';
      } else {
        log('\nPlease enter y or n');
      }
    } while (result == null);
    return result;
  }

  static void waitForEnter(String message) {
    log(message);
    stdin.readLineSync(encoding: utf8);
  }

  // Spinner
  static void setSpinnerPrefix(String prefix) {
    _spinnerPrefix = prefix;
  }

  static void clearSpinnerPrefix({
    bool shouldEndSpinner = true,
  }) {
    if (shouldEndSpinner) {
      endSpinner();
    }
    _spinnerPrefix = null;
  }

  static void startSpinner(
    String actionDescription, {
    bool overidePreviousSpinner = true,
    bool skipPrefix = false,
  }) {
    if (_cliSpinnerActionDescription != null) {
      if (!overidePreviousSpinner) {
        throw ImpaktfullCliError(
            '$_cliSpinnerActionDescription is still running, and `overidePreviousSpinner` is set to `false`');
      }
      endSpinner();
    }
    final fullDescription = _spinnerPrefix == null || skipPrefix
        ? actionDescription
        : '$_spinnerPrefix: $actionDescription';
    final message = 'Start `$fullDescription`';
    _cliSpinnerActionDescription = fullDescription;
    _cliSpinner = CliSpin(
      text: message,
    );
    if (_verbose) {
      log('⏳ $message');
    } else {
      verbose('⏳ $message');
      _cliSpinner?.start();
    }
  }

  static void failSpinner(dynamic e, StackTrace trace) {
    _printPendingLogs(toFile: true);
    if (_cliSpinnerActionDescription != null) {
      final message = 'Failed to finish: `$_cliSpinnerActionDescription`';
      if (_verbose) {
        log('❌ $message');
      } else {
        verbose('❌ $message');
        _cliSpinner?.fail(message);
      }
    }
    if (e is ImpaktfullCliExitError) {
      log('\nCli exited with the following message:\n\n\n${e.message}\n\n\n');
      return;
    }
    if (e is ImpaktfullCliError) {
      _logCliError(e);
    } else {
      error('${e.toString()}\n${trace.toString()}');
    }
    log('Full log can be found here: ${_logFile.path}');
    _cliSpinnerActionDescription = null;
    _cliSpinner = null;
  }

  static void endSpinner() {
    if (_cliSpinnerActionDescription == null) return;
    final message = 'Successfully finished: `$_cliSpinnerActionDescription`';
    if (_verbose) {
      log('✅ $message');
    } else {
      _cliSpinner?.success(message);
    }
    _cliSpinner?.stop();
    _cliSpinnerActionDescription = null;
    _cliSpinner = null;
  }

  static void stopSpinner() {
    if (_cliSpinnerActionDescription == null) return;
    _cliSpinner?.stop();
  }

  static void continueSpinner() {
    if (_cliSpinnerActionDescription == null) return;
    _cliSpinner?.start();
  }

  static void endSpinnerWithMessage(String message) {
    if (_cliSpinnerActionDescription == null) return;
    if (_verbose) {
      log('⚠️ $message');
    } else {
      _cliSpinner?.warn(message);
    }
    _cliSpinner?.stop();
    _cliSpinnerActionDescription = null;
    _cliSpinner = null;
  }

  static void saveSecret(String value) {
    if (value.isEmpty) return;
    _secrets.add(value);
  }

  static void initSecrets() => ImpaktfullCliEnvironmentVariables.initSecrets();
}
