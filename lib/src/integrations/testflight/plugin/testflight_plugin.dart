import 'dart:io';

import 'package:impaktfull_cli/src/core/model/data/environment/cli_tool.dart';
import 'package:impaktfull_cli/src/core/model/data/secret.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_process_runner_error.dart';
import 'package:impaktfull_cli/src/core/plugin/impaktfull_cli_plugin.dart';
import 'package:impaktfull_cli/src/core/util/args/env/impaktfull_cli_environment.dart';
import 'package:impaktfull_cli/src/core/util/args/env/impaktfull_cli_environment_variables.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';
import 'package:meta/meta.dart';
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
    ImpaktfullCliLogger.setSpinnerPrefix('Testflight upload');
    ImpaktfullCliLogger.startSpinner('Initializing');
    if (!file.existsSync()) {
      throw ImpaktfullCliError('File `${file.path}` does not exists');
    }
    ImpaktfullCliEnvironment.requiresMacOs(
      reason: 'Uploading to testflight can only be done on macos',
    );
    ImpaktfullCliEnvironment.requiresInstalledTools([CliTool.xcodeSelect]);
    final path = await processRunner.runProcess([
      'xcode-select',
      '--print-path',
    ]);
    final xCodeDirectory = Directory(path);
    final xCodeToolsDirectory = Directory(
      join(xCodeDirectory.path, 'usr', 'bin'),
    );
    final aToolFile = File(join(xCodeToolsDirectory.path, 'altool'));
    if (!aToolFile.existsSync()) {
      throw ImpaktfullCliError(
        '`${aToolFile.path}` does not exists, `altool` is required to upload to testflight',
      );
    }

    email = email ?? ImpaktfullCliEnvironmentVariables.getAppleEmail();
    appSpecificPassword =
        appSpecificPassword ??
        ImpaktfullCliEnvironmentVariables.getAppleAppSpecificPassword();

    ImpaktfullCliLogger.startSpinner('Uploading');
    final String output;
    try {
      output = await processRunner.runProcess([
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
    } on ImpaktfullCliProcessRunnerError catch (error) {
      throw knownUploadError(error.errorOutput) ?? error;
    }
    // altool can exit with 0 after App Store Connect rejected the upload
    // (e.g. `Validation failed (409)`), so its output is checked as well.
    final error = failedUploadError(output);
    if (error != null) throw error;
    ImpaktfullCliLogger.clearSpinnerPrefix();
  }

  /// The error for a failure altool is known to report, or null.
  @visibleForTesting
  static ImpaktfullCliError? knownUploadError(String output) {
    if (output.contains('ITunesConnectionOperationErrorDomain Code=-19000')) {
      return ImpaktfullCliError(
        'Sign in with the app-specific password you generated. If you forgot the app-specific password or need to create a new one, go to appleid.apple.com',
      );
    } else if (output.contains('The auth server returned a bad status code.')) {
      return ImpaktfullCliError(
        'Error during authentication with appstoreconnect (check email, app-specific password, connection to the internet)',
      );
    } else if (output.contains('ContentDelivery Code=-19232') ||
        output.contains('ContentDelivery Code=90062')) {
      return ImpaktfullCliError(
        'The bundle version must be higher than the previously uploaded version',
      );
    } else if (output.contains('FORBIDDEN_ERROR.CONTRACT_NOT_VALID')) {
      return ImpaktfullCliError(
        'You need to accept the latest terms and conditions in App Store Connect',
      );
    }
    return null;
  }

  /// The error for an upload whose [output] reports a failure, or null when
  /// the upload succeeded.
  @visibleForTesting
  static ImpaktfullCliError? failedUploadError(String output) {
    final known = knownUploadError(output);
    if (known != null) return known;
    final errorLines = output
        .split('\n')
        .map((line) => line.trim())
        .where(
          (line) => line.startsWith('ERROR:') || line.startsWith('*** Error:'),
        )
        .toList();
    if (!output.contains('UPLOAD FAILED') && errorLines.isEmpty) return null;
    return ImpaktfullCliError(
      [
        'Uploading to testflight failed',
        ...errorLines,
      ].join('\n'),
    );
  }
}
