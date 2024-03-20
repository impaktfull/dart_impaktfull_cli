import 'dart:io';

import 'package:impaktfull_cli/src/core/model/data/android/android_project.dart';
import 'package:impaktfull_cli/src/core/model/data/secret.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/core/plugin/impaktfull_cli_plugin.dart';
import 'package:impaktfull_cli/src/core/util/process/process_runner.dart';
import 'package:impaktfull_cli/src/integrations/android/create_keystore/model/keystore_credentials.dart';
import 'package:path/path.dart';

class AndroidCreateKeyStorePlugin extends ImpaktfullCliPlugin {
  const AndroidCreateKeyStorePlugin({
    super.processRunner = const CliProcessRunner(),
  });

  Future<KeyStoreCredentials> createKeyStore({
    required String name,
    String? dNameFullName,
    String? dNameOrganization,
    String? dNameOrganizationUnit,
    String? dNameCity,
    String? dNameState,
    String? dNameCountry,
  }) async {
    final alias = 'android';
    final keystoreFile = File(join('android', 'keystore', '$name.keystore'));
    if (keystoreFile.existsSync()) {
      throw ImpaktfullCliError(
          '${keystoreFile.path} already exist. Remove it and run the cli again if you are 100% sure you want to replace the old one.');
    }
    if (!keystoreFile.parent.existsSync()) {
      keystoreFile.parent.createSync(recursive: true);
    }
    final keyStoreCredentials = KeyStoreCredentials(
      name: name,
      storeFile: keystoreFile,
      password: Secret.random(),
      keyAlias: alias,
      dNameFullName: dNameFullName,
      dNameOrganization: dNameOrganization,
      dNameOrganizationUnit: dNameOrganizationUnit,
      dNameState: dNameState,
      dNameCity: dNameCity,
      dNameCountry: dNameCountry,
    );
    await processRunner.runProcess([
      'keytool',
      '-genkey',
      '-keyalg',
      'RSA',
      '-keystore',
      keystoreFile.path,
      '-storepass',
      keyStoreCredentials.password.value,
      '-alias',
      keyStoreCredentials.keyAlias,
      '-keypass',
      keyStoreCredentials.password.value,
      '-validity',
      '365000',
      if (keyStoreCredentials.dName != null) ...[
        '-dName',
        keyStoreCredentials.dName!,
      ],
    ]);

    final androidProject = AndroidProject(Directory('.'));
    androidProject.validate();
    androidProject.replaceSigningConfig(
        keyStoreCredentials: keyStoreCredentials);
    return keyStoreCredentials;
  }
}
