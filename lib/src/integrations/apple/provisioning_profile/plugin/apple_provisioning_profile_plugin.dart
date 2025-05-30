import 'dart:io';

import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/core/plugin/impaktfull_cli_plugin.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';
import 'package:impaktfull_cli/src/core/util/process/process_runner.dart';
import 'package:path/path.dart';

class AppleProvisioningProfilePlugin extends ImpaktfullCliPlugin {
  const AppleProvisioningProfilePlugin({
    super.processRunner = const CliProcessRunner(),
  });

  Future<void> scanAndInstallProvisioningProfiles({
    Directory? directory,
    bool override = true,
  }) async {
    final rootDirectory = directory ?? Directory.current;
    final provisioningProfiles =
        rootDirectory.listSync(recursive: true, followLinks: true);
    for (final file in provisioningProfiles) {
      if (file is File && file.path.endsWith('.mobileprovision')) {
        await installProvisioningProfile(
          provisioningProfile: file,
          override: override,
        );
      }
    }
  }

  Future<void> installProvisioningProfile({
    required File provisioningProfile,
    bool override = true,
  }) async {
    final uuid = await _retrieveUuid(provisioningProfile);
    ImpaktfullCliLogger.verbose(
        'Installing provisioning profile with UUID $uuid for ${provisioningProfile.path}');
    final targetDirectory = _targetDirectory();
    final target = File(join(targetDirectory.path, '$uuid.mobileprovision'));

    if (!targetDirectory.existsSync()) {
      await targetDirectory.create(recursive: true);
    }
    if (target.existsSync()) {
      if (override) {
        ImpaktfullCliLogger.verbose(
            'Deleting provisioning profile at ${target.path}');
        target.deleteSync(recursive: true);
      } else {
        throw ImpaktfullCliError(
            'Provisioning profile already exists at ${target.path}');
      }
    }

    await provisioningProfile.copy(target.path);
  }

  Directory _targetDirectory() {
    final home = Platform.environment['HOME'];
    return Directory('$home/Library/MobileDevice/Provisioning Profiles');
  }

  Future<String> _retrieveUuid(File profile) async {
    final result = await processRunner.runProcess(
      [
        'sh',
        '-c',
        "security cms -D -i '${profile.path.replaceAll("'", "'\\''")}' | grep -A 1 '<key>UUID</key>' | tail -n 1 | grep -Eo '>.*<' | grep -Eo '[a-z0-9-]+'",
      ],
    );
    return result.trim();
  }
}
