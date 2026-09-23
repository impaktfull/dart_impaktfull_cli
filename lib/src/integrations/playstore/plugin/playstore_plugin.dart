import 'dart:convert';
import 'dart:io';

import 'package:googleapis/androidpublisher/v3.dart';
import "package:googleapis_auth/auth_io.dart";
import 'package:impaktfull_cli/src/core/model/data/secret.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/core/plugin/impaktfull_cli_plugin.dart';
import 'package:impaktfull_cli/src/core/util/args/env/impaktfull_cli_environment.dart';
import 'package:impaktfull_cli/src/core/util/args/env/impaktfull_cli_environment_variables.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';
import 'package:impaktfull_cli/src/integrations/playstore/model/aab_manifest.dart';
import 'package:impaktfull_cli/src/integrations/playstore/model/playstore_upload_config.dart';
import 'package:path/path.dart';

class PlayStorePlugin extends ImpaktfullCliPlugin {
  PlayStorePlugin({
    required super.processRunner,
  });

  Future<void> uploadToPlayStore({
    required File file,
    required PlaystoreTrackType trackType,
    required PlaystoreReleaseStatus releaseStatus,
    File? serviceAccountCredentialsFile,
  }) async {
    ImpaktfullCliLogger.setSpinnerPrefix('PlayStore upload');
    ImpaktfullCliLogger.startSpinner('Initializing');
    if (!file.existsSync()) {
      throw ImpaktfullCliError('File `${file.path}` does not exists');
    }
    if (extension(file.path) != '.aab') {
      throw ImpaktfullCliError(
        'Only Android App Bundles (.aab) can be uploaded to the Play Store, not `${file.path}`',
      );
    }
    ImpaktfullCliLogger.startSpinner('Read package name and version');
    final manifest = AabManifest.fromFile(file);
    final packageName = manifest.packageName;
    final versionCode = manifest.versionCode.toString();
    final versionName = manifest.versionName;
    ImpaktfullCliLogger.verbose('Detected package name: `$packageName`');
    ImpaktfullCliLogger.verbose('Detected version code: `$versionCode`');
    ImpaktfullCliLogger.verbose('Detected version name: `$versionName`');
    try {
      await _runWithGoogleClient(
        serviceAccountCredentialsFile: serviceAccountCredentialsFile,
        scopes: [
          AndroidPublisherApi.androidpublisherScope,
        ],
        handler: (client) async {
          final api = AndroidPublisherApi(client);

          ImpaktfullCliLogger.startSpinner('Create new release');
          final appEdit = await api.edits.insert(
            AppEdit(),
            packageName,
          );
          final appEditId = appEdit.id;
          if (appEditId == null) {
            throw ImpaktfullCliError('AppEdit ID is null');
          }
          ImpaktfullCliLogger.startSpinner('Upload file');
          await api.edits.bundles.upload(
            packageName,
            appEditId,
            uploadMedia: Media(file.openRead(), await file.length()),
            uploadOptions: UploadOptions(),
          );

          ImpaktfullCliLogger.startSpinner(
            'Create release track (${trackType.value} - ${releaseStatus.value})',
          );
          final trackRelease = Track(
            releases: [
              TrackRelease(
                versionCodes: [
                  versionCode,
                ],
                name: versionName == null
                    ? versionCode
                    : '$versionName ($versionCode)',
                status: releaseStatus.value,
              ),
            ],
            track: trackType.value,
          );
          await api.edits.tracks.update(
            trackRelease,
            packageName,
            appEditId,
            trackType.value,
          );

          ImpaktfullCliLogger.startSpinner('Commit release');
          await api.edits.commit(
            packageName,
            appEditId,
          );
        },
      );
      ImpaktfullCliLogger.clearSpinnerPrefix();
    } on DetailedApiRequestError catch (e) {
      if (e.message == 'Version code $versionCode has already been used.') {
        throw ImpaktfullCliError(
          'The version code must be higher than the previously uploaded version. (must be higher than $versionCode)',
        );
      }
      rethrow;
    }
  }

  // Google Services Implementation
  Future<T> _runWithGoogleClient<T>({
    required File? serviceAccountCredentialsFile,
    required List<String> scopes,
    required Future<T> Function(AutoRefreshingAuthClient client) handler,
  }) async {
    AutoRefreshingAuthClient? client_;
    try {
      final serviceAccountCredentials = _getServiceAccountCredentials(
        serviceAccountCredentialsFile,
      );
      client_ = await clientViaServiceAccount(
        serviceAccountCredentials,
        scopes,
      );

      return await handler(client_);
    } finally {
      client_?.close();
    }
  }

  ServiceAccountCredentials _getServiceAccountCredentials(
    File? serviceAccountCredentialsFile,
  ) {
    ImpaktfullCliLogger.startSpinner('Assembling google service account');
    var file = serviceAccountCredentialsFile;
    if (file == null) {
      final fallbackFile = File(
        join(
          ImpaktfullCliEnvironment.instance.workingDirectory.path,
          'android',
          'playstore_credentials.json',
        ),
      );
      if (fallbackFile.existsSync()) {
        file = fallbackFile;
      }
    }
    Secret credentials;
    if (file != null && file.existsSync()) {
      credentials = Secret(file.readAsStringSync());
    } else {
      credentials =
          ImpaktfullCliEnvironmentVariables.getGoogleServiceAccountCredentials();
    }
    final serviceAccountCredentialsJson = jsonDecode(credentials.value);
    return ServiceAccountCredentials.fromJson(serviceAccountCredentialsJson);
  }
}
