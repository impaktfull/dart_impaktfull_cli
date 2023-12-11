import 'dart:io';

import 'package:impaktfull_cli/src/core/model/data/environment/cli_tool.dart';
import 'package:impaktfull_cli/src/core/model/data/secret.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/core/plugin/impaktfull_cli_plugin.dart';
import 'package:impaktfull_cli/src/core/util/args/env/impaktfull_cli_environment.dart';
import 'package:impaktfull_cli/src/core/util/args/env/impaktfull_cli_environment_variables.dart';
import 'package:path/path.dart';

class TestFlightPlugin extends ImpaktfullCliPlugin {
  const TestFlightPlugin({
    required super.processRunner,
  });

  Future<void> uploadToTestflightWithEmailPassword({
    required File file,
    String? email,
    Secret? appSpecificPassword,
    String type = 'ios',
  }) async {
    if (!file.existsSync()) {
      throw ImpaktfullCliError('File `${file.path}` does not exists');
    }
    ImpaktfullCliEnvironment.requiresMacOs(reason: 'Uploading to testflight can only be done on macos');
    ImpaktfullCliEnvironment.requiresInstalledTools([CliTool.xcodeSelect]);
    final path = await processRunner.runProcess(['xcode-select', '--print-path']);
    final xCodeDirectory = Directory(path);
    final xCodeToolsDirectory = Directory(join(xCodeDirectory.path, 'usr', 'bin'));
    final aToolFile = File(join(xCodeToolsDirectory.path, 'altool'));
    if (!aToolFile.existsSync()) {
      throw ImpaktfullCliError('`${aToolFile.path}` does not exists, `altool` is required to upload to testflight');
    }

    email = email ?? ImpaktfullCliEnvironmentVariables.getAppleEmail();
    appSpecificPassword = appSpecificPassword ?? ImpaktfullCliEnvironmentVariables.getAppleAppSpecificPassword();

    final result = await processRunner.runProcess([
      aToolFile.path,
      '--upload-app',
      '--file',
      file.path,
      '--username',
      email,
      '--password',
      appSpecificPassword.value,
      '--type',
      type,
    ]);
    if (result.contains('ITunesConnectionOperationErrorDomain Code=-19000')) {
      throw ImpaktfullCliError(
          'Sign in with the app-specific password you generated. If you forgot the app-specific password or need to create a new one, go to appleid.apple.com');
    } else if (result.contains('The auth server returned a bad status code.')) {
      throw ImpaktfullCliError('Error during authentication with appstoreconnect (check email, app-specific password, connection to the internet)');
    } else if (result.contains('ContentDelivery Code=-19232') || result.contains('ContentDelivery Code=90062')) {
      throw ImpaktfullCliError('The bundle version must be higher than the previously uploaded version');
    }
  }
}
