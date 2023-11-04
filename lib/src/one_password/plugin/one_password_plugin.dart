import 'dart:io';

import 'package:impaktfull_cli/src/cli/model/data/secret.dart';
import 'package:impaktfull_cli/src/cli/plugin/cli_plugin.dart';

class OnePasswordPlugin extends ImpaktfullCliPlugin {
  const OnePasswordPlugin({
    super.processRunner,
  });

  Future<File> downloadDistributionCertificate({
    required String opUuid,
    String outputPath = 'certificates/apple_distribution.p12',
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
}
