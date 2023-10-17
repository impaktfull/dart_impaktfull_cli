import 'dart:io';

import 'package:impaktfull_cli/src/model/data/secret.dart';
import 'package:impaktfull_cli/src/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/util/logger/logger.dart';

class ImpaktfullCliInputReader {
  const ImpaktfullCliInputReader._();

  static Secret readSecret(String message) {
    ImpaktfullCliLogger.debug('$message:');
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
