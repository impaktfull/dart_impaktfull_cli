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
    String name,
    Secret password,
  ) async {
    final keyChainPath = await _getKeyChainPath(name);
    if (keyChainPath != null) {
      throw ImpaktfullCliError(
          '`$name` keychain already exists, make sure to remove it first.');
    }

    final fullKeyChainName = _fullKeyChainName(name);
    ImpaktfullCliLogger.debug('Create Apple KeyChain ($fullKeyChainName)');
    await processRunner.runProcess([
      'security',
      'create-keychain',
      '-p',
      password.value,
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
    String name,
    Secret password,
  ) async {
    final keyChainPath = await _getKeyChainPath(name);
    if (keyChainPath == null) {
      throw ImpaktfullCliError(
          '`$name` keychain does not exists. In order to unlock a keychain, it should be created first.');
    }
    await processRunner
        .runProcess(['security', 'set-keychain-settings', keyChainPath]);
    await processRunner.runProcess(
        ['security', 'unlock-keychain', '-p', password.value, keyChainPath]);
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
          ],
        ],
      ],
    ]);
  }

  Future<void> removeKeyChain(
    String name,
  ) async {
    final fullKeyChainName = _fullKeyChainName(name);
    ImpaktfullCliLogger.debug('Remove Apple KeyChain ($fullKeyChainName)');
    await processRunner
        .runProcess(['security', 'delete-keychain', fullKeyChainName]);
  }

  Future<void> setDefaultKeyChain(String name) async {
    final path = await _getKeyChainPath(name);
    if (path == null) {
      throw ImpaktfullCliError(
          '`$name` keychain does not exists. In order to set the default keychain, it should be created first.');
    }
    ImpaktfullCliLogger.debug('Set default Apple KeyChain ($path)');
    await processRunner.runProcess(['security', 'list-keychains', '-s', path]);
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
