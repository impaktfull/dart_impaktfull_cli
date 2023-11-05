import 'dart:io';

import 'package:impaktfull_cli/src/cli/model/data/environment/cli_tool.dart';
import 'package:impaktfull_cli/src/cli/model/data/secret.dart';
import 'package:impaktfull_cli/src/cli/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/cli/plugin/cli_plugin.dart';
import 'package:impaktfull_cli/src/cli/util/args/env/impaktfull_cli_environment.dart';
import 'package:path/path.dart';

class TestFlightPlugin extends ImpaktfullCliPlugin {
  const TestFlightPlugin({
    required super.processRunner,
  });

  Future<void> uploadToTestflightWithEmailPassword({
    required File filePath,
    required String userName,
    required Secret password,
  }) async =>
      _uploadToTestflight(
        file: filePath,
        userName: userName,
        password: password,
      );

  Future<void> uploadToTestflightWithApiKey({
    required File filePath,
    required String issuerId,
    required Secret apiKey,
  }) async =>
      _uploadToTestflight(
        file: filePath,
        issuerId: issuerId,
        apiKey: apiKey,
      );

  Future<void> _uploadToTestflight({
    required File file,
    String? userName,
    Secret? password,
    String? issuerId,
    Secret? apiKey,
  }) async {
    if (!file.existsSync()) {
      throw ImpaktfullCliError('File `${file.path}` does not exists');
    }
    ImpaktfullCliEnvironment.requiresMacOs(
        reason: 'Uploading to testflight can only be done on macos');
    ImpaktfullCliEnvironment.requiresInstalledTools([CliTool.xcodeSelect]);
    final path =
        await processRunner.runProcess(['xcode-select', '--print-path']);
    final xCodeDirectory = Directory(path);
    final xCodeToolsDirectory =
        Directory(join(xCodeDirectory.path, 'usr', 'bin'));
    final aToolFile = File(join(xCodeToolsDirectory.path, 'altool'));
    if (!aToolFile.existsSync()) {
      throw ImpaktfullCliError(
          '`${aToolFile.path}` does not exists, `altool` is required to upload to testflight');
    }
    final hasEmailPasswordConfig = userName == null || password == null;
    final hasApiKeyWithIssuerConfig = apiKey == null || issuerId == null;
    if (!hasApiKeyWithIssuerConfig && !hasApiKeyWithIssuerConfig) {
      throw ImpaktfullCliError(
          'In order to authenticate `username` + `password` or `apiKey + issuerId` is required');
    }
    final result = await processRunner.runProcessVerbose([
      aToolFile.path,
      '--upload-app',
      '--file',
      file.path,
      if (!hasApiKeyWithIssuerConfig) ...[
        '--apiIssuer',
        issuerId,
        '--api_key',
        apiKey.value,
      ] else if (!hasEmailPasswordConfig) ...[
        '--username',
        userName,
        '--password',
        password.value,
      ],
      '--type',
      'ios',
    ]);
    if (result.contains('ITunesConnectionOperationErrorDomain Code=-19000')) {
      throw ImpaktfullCliError(
          'Sign in with the app-specific password you generated. If you forgot the app-specific password or need to create a new one, go to appleid.apple.com');
    } else if (result.contains('The auth server returned a bad status code.')) {
      throw ImpaktfullCliError(
          'Error during authentication with appstoreconnect (check email, app-specific password, connection to the internet)');
    } else if (result.contains('ContentDelivery Code=-19232')) {
      throw ImpaktfullCliError(
          'The bundle version must be higher than the previously uploaded version');
    }
  }
}
