import 'dart:io';

import 'package:impaktfull_cli/src/core/model/data/secret.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/core/plugin/impaktfull_cli_plugin.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';
import 'package:impaktfull_cli/src/core/util/process/process_runner.dart';

class MacOsKeyChainPlugin extends ImpaktfullCliPlugin {
  const MacOsKeyChainPlugin({
    super.processRunner = const CliProcessRunner(),
  });

  String _fullKeyChainName(String keyChainName) => '$keyChainName.keychain';

  Future<void> createKeyChain(
    String keyChainName,
    Secret globalKeyChainPassword,
  ) async {
    final keyChainPath = await _getKeyChainPath(keyChainName);
    if (keyChainPath != null) {
      throw ImpaktfullCliError(
          '`$keyChainName` keychain already exists, make sure to remove it first.');
    }

    final fullKeyChainName = _fullKeyChainName(keyChainName);
    ImpaktfullCliLogger.debug('Create Apple KeyChain ($fullKeyChainName)');
    await processRunner.runProcess([
      'security',
      'create-keychain',
      '-p',
      globalKeyChainPassword.value,
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
      globalKeyChainPassword.value,
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
    await processRunner.runProcess([
      'security',
      'import',
      certFile.path,
      '-k',
      fullKeyChainName,
      '-P',
      certPassword.value,
      if (accessControlAll) ...[
        '-A',
      ] else ...[
        for (final application in accessControlApplications) ...[
          ...[
            '-T',
            application,
          ]
        ],
      ],
    ]);
  }

  Future<void> removeKeyChain(
    String keyChainName,
  ) async {
    final fullKeyChainName = _fullKeyChainName(keyChainName);
    ImpaktfullCliLogger.debug('Remove Apple KeyChain ($fullKeyChainName)');
    await processRunner
        .runProcess(['security', 'delete-keychain', fullKeyChainName]);
  }

  /// Sets the default keychain to the given keychain.
  /// If the keychain is not found, an error is thrown.
  /// keyChain can be a name or a path
  Future<void> setDefaultKeyChain(String keyChain) async {
    final path = await _getKeyChainPath(keyChain);
    if (path == null) {
      throw ImpaktfullCliError('Keychain path $keyChain not found');
    }
    ImpaktfullCliLogger.debug('Set default Apple KeyChain ($path)');
    await processRunner
        .runProcess(['security', 'default-keychain', '-s', path]);
  }

  Future<String> getDefaultKeyChain() async {
    final keychainsString =
        await processRunner.runProcess(['security', 'default-keychain']);
    return keychainsString.trim().replaceAll('"', '');
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

  Future<String?> _getKeyChainPath(String keyChain) async {
    final userKeyChains = await _getUserKeyChains();
    for (final userKeyChain in userKeyChains) {
      if (userKeyChain.contains(keyChain)) {
        return userKeyChain;
      }
    }
    return null;
  }

  Future<void> printKeyChainList() async {
    final keyChains = await _getUserKeyChains();
    final sb = StringBuffer();
    for (final keyChain in keyChains) {
      sb.writeln('\t"$keyChain"');
    }
    ImpaktfullCliLogger.debug(sb.toString());
  }
}
