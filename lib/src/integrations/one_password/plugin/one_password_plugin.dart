import 'dart:io';

import 'package:impaktfull_cli/src/core/model/data/secret.dart';
import 'package:impaktfull_cli/src/core/plugin/impaktfull_cli_plugin.dart';
import 'package:impaktfull_cli/src/core/util/args/env/impaktfull_cli_environment_variables.dart';
import 'package:impaktfull_cli/src/integrations/testflight/model/testflight_credentials.dart';

class OnePasswordPlugin extends ImpaktfullCliPlugin {
  String get serviceAccountEnvKey =>
      ImpaktfullCliEnvironmentVariables.envKeyOnePasswordAccountToken;

  const OnePasswordPlugin({
    required super.processRunner,
  });

  Future<String> _executeOnePasswordCommand<T>(
    List<String> args, {
    Secret? rawServiceAccount,
  }) async =>
      processRunner.runProcess(
        args,
        environment: {
          if (rawServiceAccount != null) ...{
            serviceAccountEnvKey: rawServiceAccount.value,
          },
        },
      );

  Future<File> downloadFile({
    required String opUuid,
    required String outputPath,
    String? vaultName,
    Secret? rawServiceAccount,
  }) async {
    final exportFile = File(outputPath);
    await _executeOnePasswordCommand(
      [
        'op',
        'document',
        'get',
        '"$opUuid"',
        '--out-file',
        '"${exportFile.path}"',
        if (vaultName != null) ...[
          '--vault',
          vaultName,
        ],
      ],
      rawServiceAccount: rawServiceAccount,
    );
    return exportFile;
  }

  Future<Secret> getCertificatePassword({
    required String opUuid,
    String vaultName = 'Certificates',
    String fieldName = 'password',
    Secret? rawServiceAccount,
  }) =>
      getPassword(
        vaultName: vaultName,
        opUuid: opUuid,
        fieldName: fieldName,
        rawServiceAccount: rawServiceAccount,
      );

  Future<Secret> getPassword({
    required String vaultName,
    required String opUuid,
    required String fieldName,
    Secret? rawServiceAccount,
  }) async {
    final result = await getOnePasswordField(
      vaultName: vaultName,
      opUuid: opUuid,
      fieldName: fieldName,
      rawServiceAccount: rawServiceAccount,
    );
    return Secret(result);
  }

  Future<String> getOnePasswordField({
    required String vaultName,
    required String opUuid,
    required String fieldName,
    Secret? rawServiceAccount,
  }) async =>
      _executeOnePasswordCommand(
        [
          'op',
          'read',
          'op://$vaultName/$opUuid/$fieldName',
        ],
        rawServiceAccount: rawServiceAccount,
      );

  Future<File> downloadDistributionCertificate({
    required String opUuid,
    String? vaultName,
    String outputPath = 'certificates/apple_distribution.p12',
    Secret? rawServiceAccount,
  }) =>
      downloadFile(
        opUuid: opUuid,
        outputPath: outputPath,
        rawServiceAccount: rawServiceAccount,
      );

  Future<TestFlightCredentials> getTestFlightCredentials({
    required String vaultName,
    required String opUuid,
    Secret? rawServiceAccount,
  }) async =>
      TestFlightCredentials(
        userName: await getOnePasswordField(
          vaultName: vaultName,
          opUuid: opUuid,
          fieldName: 'username',
          rawServiceAccount: rawServiceAccount,
        ),
        appSpecificPassword: await getPassword(
          vaultName: vaultName,
          opUuid: opUuid,
          fieldName: 'password',
          rawServiceAccount: rawServiceAccount,
        ),
      );

  Future<File> downloadServiceAccountCredentials({
    required String opUuid,
    String outputPath = 'android/playstore_credentials.json',
    String? vaultName,
    Secret? rawServiceAccount,
  }) async =>
      downloadFile(
        opUuid: opUuid,
        outputPath: outputPath,
        vaultName: vaultName,
        rawServiceAccount: rawServiceAccount,
      );
}
