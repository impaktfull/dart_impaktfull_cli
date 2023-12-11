import 'dart:io';

import 'package:impaktfull_cli/src/core/model/data/secret.dart';
import 'package:impaktfull_cli/src/core/plugin/impaktfull_cli_plugin.dart';
import 'package:impaktfull_cli/src/integrations/testflight/model/testflight_credentials.dart';

class OnePasswordPlugin extends ImpaktfullCliPlugin {
  const OnePasswordPlugin({
    required super.processRunner,
  });

  Future<File> downloadFile({
    required String opUuid,
    required String outputPath,
  }) async {
    final exportFile = File(outputPath);
    await processRunner.runProcess([
      'op',
      'document',
      'get',
      '"$opUuid"',
      '--out-file',
      '"${exportFile.path}"'
    ]);
    return exportFile;
  }

  Future<Secret> getCertificatePassword({
    required String opUuid,
    String vaultName = 'Certificates',
    String fieldName = 'password',
  }) =>
      getPassword(vaultName: vaultName, opUuid: opUuid, fieldName: fieldName);

  Future<Secret> getPassword({
    required String opUuid,
    required String vaultName,
    required String fieldName,
  }) async {
    final result = await getOnePasswordField(
        vaultName: vaultName, opUuid: opUuid, fieldName: fieldName);
    return Secret(result);
  }

  Future<String> getOnePasswordField({
    required String vaultName,
    required String opUuid,
    required String fieldName,
  }) =>
      processRunner
          .runProcess(['op', 'read', 'op://$vaultName/$opUuid/$fieldName']);

  Future<File> downloadDistributionCertificate({
    required String opUuid,
    String outputPath = 'certificates/apple_distribution.p12',
  }) =>
      downloadFile(
        opUuid: opUuid,
        outputPath: outputPath,
      );

  Future<TestFlightCredentials> getTestFlightCredentials({
    required String vaultName,
    required String opUuid,
  }) async =>
      TestFlightCredentials(
        userName: await getOnePasswordField(
          vaultName: vaultName,
          opUuid: opUuid,
          fieldName: 'username',
        ),
        appSpecificPassword: await getPassword(
          vaultName: vaultName,
          opUuid: opUuid,
          fieldName: 'password',
        ),
      );

  Future<File> downloadServiceAccountCredentials({
    required String opUuid,
    String outputPath = 'android/playstore_credentials.json',
  }) async =>
      downloadFile(opUuid: opUuid, outputPath: outputPath);
}
