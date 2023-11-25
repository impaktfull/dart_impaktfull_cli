import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/core/util/args/env/impaktfull_cli_environment_variables.dart';

class ImpaktfullCliLogger {
  static final _secrets = <String>[];
  static bool _verbose = false;
  static const String _separator =
      '==========================================================================================';

  ImpaktfullCliLogger._();

  static void init({bool isVerboseLoggingEnabled = false}) {
    _verbose = isVerboseLoggingEnabled;
    initSecrets();
    if (isVerboseLoggingEnabled) {
      ImpaktfullCliLogger.verbose('Verbose logging enabled');
    }
  }

  static void log(String message) => debug(message);

  static void debug(String message) => _print(message);
  static void logSeperator() => log(_separator);
  static void debugSeperator() => debug(_separator);
  static void verboseSeperator() => verbose(_separator);

  static void error(String message) {
    if (message.startsWith('[ERROR]')) {
      _print(message);
    } else {
      _print('[ERROR] $message');
    }
  }

  static void argumentError(Object error) {
    final sb = StringBuffer();
    sb.writeln();
    sb.writeln(_separator);
    if (error is ImpaktfullCliError) {
      sb.writeln('ImpaktfullCliError:');
      sb.writeln(error.message);
    } else {
      sb.writeln('Something went wrong:');
      sb.writeln(error.toString());
    }
    sb.writeln(_separator);
    debug(sb.toString());
  }

  static void verbose(String message) {
    if (!_verbose) return;
    _print(message);
  }

  static void _print(String message) {
    var safeMessage = message;
    if (!_verbose) {
      for (final secret in _secrets) {
        safeMessage = safeMessage.replaceAll(secret, '****');
      }
    }
    print(safeMessage);
  }

  static void saveSecret(String value) {
    if (value.isEmpty) return;
    _secrets.add(value);
  }

  static void initSecrets() => ImpaktfullCliEnvironmentVariables.initSecrets();
}
