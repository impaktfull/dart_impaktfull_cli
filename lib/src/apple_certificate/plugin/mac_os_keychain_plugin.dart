import 'dart:io';

import 'package:impaktfull_cli/src/cli/model/data/secret.dart';
import 'package:impaktfull_cli/src/cli/plugin/cli_plugin.dart';
import 'package:impaktfull_cli/src/cli/util/logger/logger.dart';

class MacOsKeyChainPlugin extends ImpaktfullCliPlugin {
  const MacOsKeyChainPlugin({
    super.processRunner,
  });

  String _fullKeyChainName(String keyChainName) => '$keyChainName.keychain';

  Future<void> createKeyChain(
    String keyChainName,
    Secret globalKeyChainPassword,
  ) async {
    final fullKeyChainName = _fullKeyChainName(keyChainName);
    CliLogger.debug('Create Apple KeyChain ($fullKeyChainName)');
    await processRunner.runProcess([
      'security',
      'create-keychain',
      '-p',
      '$globalKeyChainPassword',
      fullKeyChainName
    ]);
    final keyChain = await _getUserKeyChains();
    await processRunner.runProcess([
      'security',
      'list-keychains',
      '-d',
      'user',
      '-s',
      fullKeyChainName,
      ...keyChain
    ]);
  }

  Future<void> unlockKeyChain(
    String keyChainName,
    Secret globalKeyChainPassword,
  ) async {
    final fullKeyChainName = _fullKeyChainName(keyChainName);
    await processRunner
        .runProcess(['security', 'set-keychain-settings', fullKeyChainName]);
    await processRunner.runProcess([
      'security',
      'unlock-keychain',
      '-p',
      '$globalKeyChainPassword',
      fullKeyChainName
    ]);
  }

  Future<void> addCertificateToKeyChain(
    String keyChainName,
    File certFile,
    Secret certPassword, {
    bool accessControlAll = false,
    List<String> accessControlApplications = const [
      '/usr/bin/codesign',
    ],
  }) async {
    final fullKeyChainName = _fullKeyChainName(keyChainName);
    if (accessControlAll) {
      await processRunner.runProcess([
        'security',
        'import',
        '"${certFile.path}"',
        '-k',
        fullKeyChainName,
        '-P',
        '"$certPassword"',
        '-A'
      ]);
    } else if (accessControlApplications.isNotEmpty) {
      await processRunner.runProcess([
        'security',
        'import',
        '"${certFile.path}"',
        '-k',
        fullKeyChainName,
        '-P',
        '"$certPassword"',
        for (final application in accessControlApplications) ...[
          ...[
            '-T',
            application,
          ]
        ]
      ]);
    } else {
      await processRunner.runProcess([
        'security',
        'import',
        '"${certFile.path}"',
        '-k',
        fullKeyChainName,
        '-P',
        '"$certPassword"'
      ]);
    }
  }

  Future<void> removeKeyChain(
    String keyChainName,
  ) async {
    final fullKeyChainName = _fullKeyChainName(keyChainName);
    CliLogger.debug('Remove Apple KeyChain ($fullKeyChainName)');
    await processRunner
        .runProcess(['security', 'delete-keychain', fullKeyChainName]);
  }

  Future<List<String>> _getUserKeyChains() async {
    final keychainsString = await processRunner
        .runProcess(['security', 'list-keychains', '-d', 'user']);
    final keychainsList =
        keychainsString.split('\n').where((element) => element.isNotEmpty);
    return keychainsList
        .map((keychain) => keychain.replaceAll('"', '').trim())
        .toList();
  }

  Future<void> printKeyChainList() async {
    final keyChains = await _getUserKeyChains();
    final sb = StringBuffer();
    for (final keyChain in keyChains) {
      sb.writeln('\t"$keyChain"');
    }
    CliLogger.debug(sb.toString());
  }
}
