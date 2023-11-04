import 'dart:io';

import 'package:impaktfull_cli/src/cli/model/data/secret.dart';
import 'package:impaktfull_cli/src/cli/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/cli/util/logger/logger.dart';

class CliInputReader {
  const CliInputReader._();

  static Secret readSecret(String message) {
    CliLogger.debug('$message:');
    stdin.echoMode = false;
    final secretValue = stdin.readLineSync();
    if (secretValue == null || secretValue.isEmpty) {
      throw ImpaktfullCliError('No secret entered!');
    }
    stdin.echoMode = true;
    return Secret(secretValue);
  }

  static Secret readKeyChainPassword() =>
      readSecret('Enter global keychain password');
}
