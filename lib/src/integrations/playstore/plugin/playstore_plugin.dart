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
import 'package:path/path.dart';

class PlayStorePlugin extends ImpaktfullCliPlugin {
  const PlayStorePlugin({
    required super.processRunner,
  });

  Future<void> uploadToPlayStore({
    required File file,
    File? serviceAccountCredentialsFile,
  }) async {
    if (!file.existsSync()) {
      throw ImpaktfullCliError('File `${file.path}` does not exists');
    }
    final packageName = await _getPackageName(file);
    ImpaktfullCliLogger.verbose('Detected package name: `$packageName`');
    return _runWithGoogleClient(
      serviceAccountCredentialsFile: serviceAccountCredentialsFile,
      scopes: [
        AndroidPublisherApi.androidpublisherScope,
      ],
      handler: (client) async {
        final api = AndroidPublisherApi(client);

        final appEdit = await api.edits.insert(AppEdit(), packageName);
        final appEditId = appEdit.id;
        if (appEditId == null) {
          throw ImpaktfullCliError('AppEdit ID is null');
        }
        await api.edits.bundles.upload(
          packageName,
          appEditId,
          uploadMedia: Media(file.openRead(), await file.length()),
          uploadOptions: UploadOptions(),
        );
        await api.edits.commit(packageName, appEditId);
      },
    );
  }

  // Google Services Implementation
  Future<T> _runWithGoogleClient<T>({
    required File? serviceAccountCredentialsFile,
    required List<String> scopes,
    required Future<T> Function(AutoRefreshingAuthClient client) handler,
  }) async {
    AutoRefreshingAuthClient? client_;
    try {
      final serviceAccountCredentials =
          _getServiceAccountCredentials(serviceAccountCredentialsFile);
      client_ =
          await clientViaServiceAccount(serviceAccountCredentials, scopes);

      return await handler(client_);
    } finally {
      client_?.close();
    }
  }

  ServiceAccountCredentials _getServiceAccountCredentials(
      File? serviceAccountCredentialsFile) {
    var file = serviceAccountCredentialsFile;
    if (file == null) {
      final fallbackFile = File(join(
        ImpaktfullCliEnvironment.instance.workingDirectory.path,
        'android',
        'playstore_credentials.json',
      ));
      if (fallbackFile.existsSync()) {
        file = fallbackFile;
      }
    }
    Secret credentials;
    if (file != null && file.existsSync()) {
      credentials = Secret(file.readAsStringSync());
    } else {
      credentials = ImpaktfullCliEnvironmentVariables
          .getGoogleServiceAccountCredentials();
    }
    final serviceAccountCredentialsJson = jsonDecode(credentials.value);
    return ServiceAccountCredentials.fromJson(serviceAccountCredentialsJson);
  }

  Future<String> _getPackageName(File file) async {
    final fileExtension = extension(file.path);
    if (fileExtension == '.aab') {
      final apksFile = File('app.apks');
      final apksZipFile = File('aab_to_apks.zip');
      final apkOutputDirectory = Directory(join('tmp', 'aab_to_apk_output'));
      final baseApkFile =
          File(join(apkOutputDirectory.path, 'splits', 'base-master.apk'));
      await processRunner.runProcess([
        'bundletool',
        'build-apks',
        '--bundle=${file.path}',
        '--output=${apksFile.path}'
      ]);
      apksFile.renameSync(apksZipFile.path);
      if (apkOutputDirectory.existsSync()) {
        apkOutputDirectory.deleteSync(recursive: true);
      }
      apkOutputDirectory.createSync(recursive: true);
      await processRunner.runProcess(
          ['unzip', apksZipFile.path, '-d', apkOutputDirectory.path]);
      apksZipFile.deleteSync(recursive: true);
      final packageName = await _getPackageName(baseApkFile);
      apkOutputDirectory.deleteSync(recursive: true);
      return packageName;
    } else if (fileExtension == '.apk') {
      return processRunner
          .runProcess(['aapt2', 'dump', 'packagename', file.path]);
    } else {
      throw ImpaktfullCliError(
          'Automatic detection of the package name is currently only supported for [.aab & .apk] files');
    }
  }
}
