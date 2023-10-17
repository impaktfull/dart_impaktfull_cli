import 'package:args/args.dart';
import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/command/cli_command.dart';

class ImpaktfullCliLogger {
  static final _secrets = <String>[];
  static bool _verbose = false;

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
  static void logSeperator() => log(
      '==========================================================================================');
  static void debugSeperator() => debug(
      '==========================================================================================');
  static void verboseSeperator() => verbose(
      '==========================================================================================');

  static void error(String message) {
    if (message.startsWith('[ERROR]')) {
      _print(message);
    } else {
      _print('[ERROR] $message');
    }
  }

  static void argumentError(
    Object error, {
    required ArgParser argParser,
    List<CliCommand<dynamic>> commands = const [],
    String? commandName,
  }) {
    final sb = StringBuffer();
    sb.writeln();
    sb.writeln(
        '================================================================================');
    if (error is ImpaktfullCliArgumentError) {
      sb.writeln('ImpaktfullCliArgumentError:');
    } else {
      sb.writeln('Something went wrong:');
    }
    sb.writeln(error.toString());
    sb.writeln(
        '================================================================================');
    sb.write('Help Menu');
    if (commandName != null) {
      sb.write(' for `$commandName`');
    }
    sb.write(':');
    sb.writeln();
    if (commands.isNotEmpty) {
      final allCommands = commands.map((e) => e.name).toList();
      sb.writeln();
      sb.writeln('Configured commands:');
      sb.writeln('- ${allCommands.join('\n- ')}');
    }
    sb.writeln();
    sb.writeln('Options:');
    sb.writeln(argParser.usage);
    sb.writeln(
        '================================================================================');
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
