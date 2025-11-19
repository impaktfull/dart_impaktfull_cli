import 'dart:io';

import 'package:impaktfull_cli/src/core/model/data/secret.dart';
import 'package:impaktfull_cli/src/core/plugin/impaktfull_cli_plugin.dart';
import 'package:impaktfull_cli/src/core/util/args/env/impaktfull_cli_environment_variables.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';
import 'package:impaktfull_cli/src/integrations/testflight/model/testflight_credentials.dart';

const _storedFilesToRemove = <File>[];

class OnePasswordPlugin extends ImpaktfullCliPlugin {
  String get serviceAccountEnvKey =>
      ImpaktfullCliEnvironmentVariables.envKeyOnePasswordAccountToken;

  const OnePasswordPlugin({
    required super.processRunner,
  });

  Future<String> _executeOnePasswordCommand<T>(
    List<String> args, {
    required String log,
    Secret? rawServiceAccount,
  }) async {
    ImpaktfullCliLogger.startSpinner(
      '1Password: $log',
      skipPrefix: true,
    );
    final result = await processRunner.runProcess(
      args,
      environment: {
        if (rawServiceAccount != null) ...{
          serviceAccountEnvKey: rawServiceAccount.value,
        },
      },
      maskOutput: true,
    );
    ImpaktfullCliLogger.endSpinner();
    return result;
  }

  Future<File> downloadFile({
    required String opUuid,
    required String outputPath,
    String? vaultName,
    Secret? rawServiceAccount,
    String? logContext,
    bool removeFileAfterCliRun = true,
  }) async {
    final exportFile = File(outputPath);
    if (!exportFile.existsSync()) {
      exportFile.createSync(recursive: true);
    }
    ImpaktfullCliLogger.verbose('Deleting existing file: $outputPath');
    exportFile.deleteSync(recursive: true);
    await _executeOnePasswordCommand(
      [
        'op',
        'document',
        'get',
        opUuid,
        '--out-file',
        exportFile.path,
        if (vaultName != null) ...[
          '--vault',
          vaultName,
        ],
      ],
      log:
          'Downloading file from 1Password ${logContext == null ? '' : '($logContext)'}',
      rawServiceAccount: rawServiceAccount,
    );
    if (removeFileAfterCliRun) {
      if (exportFile.existsSync()) {
        _storedFilesToRemove.add(exportFile);
      }
    }
    return exportFile;
  }

  Future<Secret> getCertificatePassword({
    required String opUuid,
    required String vaultName,
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
    String? logContext,
  }) async {
    final result = await getOnePasswordField(
      vaultName: vaultName,
      opUuid: opUuid,
      fieldName: fieldName,
      rawServiceAccount: rawServiceAccount,
      logContext: logContext,
    );
    return Secret(result);
  }

  Future<String> getOnePasswordField({
    required String vaultName,
    required String opUuid,
    required String fieldName,
    Secret? rawServiceAccount,
    String? logContext,
  }) async =>
      _executeOnePasswordCommand(
        [
          'op',
          'read',
          'op://$vaultName/$opUuid/$fieldName',
        ],
        log:
            'Reading field ($fieldName) from 1Password ${logContext == null ? null : '($logContext)'}',
        rawServiceAccount: rawServiceAccount,
      );

  Future<File> downloadDistributionCertificate({
    required String opUuid,
    String? vaultName,
    String outputPath = 'certificates/apple_distribution.p12',
    Secret? rawServiceAccount,
    bool removeFileAfterCliRun = true,
  }) =>
      downloadFile(
        opUuid: opUuid,
        outputPath: outputPath,
        rawServiceAccount: rawServiceAccount,
        removeFileAfterCliRun: removeFileAfterCliRun,
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
          logContext: 'Service Account Credentials',
        ),
      );

  Future<File> downloadServiceAccountCredentials({
    required String opUuid,
    String outputPath = 'android/playstore_credentials.json',
    String? vaultName,
    Secret? rawServiceAccount,
    bool removeFileAfterCliRun = true,
  }) async =>
      downloadFile(
        opUuid: opUuid,
        outputPath: outputPath,
        vaultName: vaultName,
        rawServiceAccount: rawServiceAccount,
        logContext: 'Service Account Credentials',
        removeFileAfterCliRun: removeFileAfterCliRun,
      );

  Future<void> cleanupStoredFiles() async {
    for (final file in _storedFilesToRemove) {
      if (file.existsSync()) {
        file.deleteSync(recursive: true);
      }
    }
    _storedFilesToRemove.clear();
  }
}
