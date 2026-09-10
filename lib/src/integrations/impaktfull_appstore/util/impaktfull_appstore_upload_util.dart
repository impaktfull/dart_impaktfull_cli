import 'dart:io';

import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_appstore/model/impaktfull_appstore_build.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_appstore/model/impaktfull_appstore_ci_metadata.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_appstore/model/impaktfull_appstore_upload_config.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_appstore/util/impaktfull_appstore_api.dart';
import 'package:path/path.dart';

/// The upload, in the order the server expects it.
///
/// ```
/// GET    /api/ci/app                      validate the key, resolve the name
/// POST   /api/ci/builds                   declare size and checksum
/// PUT    <presigned url>                  the bytes, straight to storage
/// POST   /api/ci/builds/:id/complete      hand it to the inspector
/// GET    /api/ci/builds/:id               poll until it stops processing
/// ```
///
/// Four of those five exist so a failure happens EARLY and says why. The old
/// App Testing upload was one call: it sent the file, and whether anybody could
/// install what came out the other end was discovered by a tester.
class ImpaktfullAppstoreUploadUtil {
  static const allowedExtensions = ['ipa', 'apk'];

  const ImpaktfullAppstoreUploadUtil();

  Future<ImpaktfullAppstoreBuild> upload({
    required File file,
    required ImpaktfullAppstoreUploadConfig config,
  }) async {
    if (!file.existsSync()) {
      throw ImpaktfullCliError('`${file.path}` does not exist');
    }
    _validateExtension(file);

    final api = ImpaktfullAppstoreApi(
      baseUrl: config.baseUrl,
      uploadKey: config.credentials.uploadKey,
    );

    try {
      ImpaktfullCliLogger.startSpinner('Validating the upload key');
      final app = await api.getApp();
      final environment = _resolveEnvironment(app, config.environmentName);
      ImpaktfullCliLogger.verbose(
        'Uploading to ${app.name} (${environment.label}, '
        '${environment.appIdentifier})',
      );
      _validateExtensionMatchesPlatform(file, environment);

      final sizeBytes = await file.length();

      // The checksum BEFORE the transfer, because the server dedupes on it: the
      // same artifact uploaded twice becomes one build rather than two copies
      // of the same bytes under two version numbers.
      ImpaktfullCliLogger.startSpinner('Calculating the checksum');
      final sha256 = await ImpaktfullAppstoreApi.hashFile(file);

      ImpaktfullCliLogger.startSpinner('Creating the build');
      final ci = config.ci ?? ImpaktfullAppstoreCiMetadata.fromEnvironment();
      final ticket = await api.initiateUpload(
        environmentName: environment.name,
        fileName: basename(file.path),
        sizeBytes: sizeBytes,
        sha256: sha256,
        releaseNotes: config.releaseNotes,
        ci: ci.isEmpty ? null : ci.toJson(),
      );

      if (ticket.upload == null) {
        // Either the server already had these bytes, or this build has already
        // moved on to the inspector. A pipeline that retried a step which
        // already succeeded has done nothing wrong, so this is not an error.
        ImpaktfullCliLogger.verbose(
          ticket.isDuplicate
              ? 'The server already has this artifact; nothing to transfer.'
              : 'This build is already being processed; nothing to transfer.',
        );
      } else {
        await _transfer(
          api: api,
          ticket: ticket,
          file: file,
          sizeBytes: sizeBytes,
        );

        ImpaktfullCliLogger.startSpinner('Completing the upload');
        await api.completeUpload(ticket.build.id);
      }

      if (!config.waitForProcessing) {
        return api.getBuild(ticket.build.id);
      }
      return _waitForProcessing(
        api: api,
        buildId: ticket.build.id,
        timeout: config.processingTimeout,
      );
    } finally {
      api.dispose();
    }
  }

  /// The transfer, with the build cancelled if it does not finish.
  ///
  /// An interrupted pipeline would otherwise leave a row in `uploading` that
  /// counts against the app's five-in-flight cap for an hour, and the next
  /// person to release would be told the app has too many uploads pending with
  /// nothing they can do about it.
  Future<void> _transfer({
    required ImpaktfullAppstoreApi api,
    required ImpaktfullAppstoreUploadTicket ticket,
    required File file,
    required int sizeBytes,
  }) async {
    try {
      var lastReported = -1;
      await api.uploadArtifact(
        url: ticket.upload!.url,
        headers: ticket.upload!.headers,
        file: file,
        sizeBytes: sizeBytes,
        onProgress: (sent, total) {
          final percentage = total == 0 ? 100 : (sent * 100) ~/ total;
          // Only on a whole percent. A spinner rewritten per chunk is a
          // megabyte of escape codes in a CI log that does not render them.
          if (percentage == lastReported) return;
          lastReported = percentage;
          ImpaktfullCliLogger.startSpinner('Uploading: $percentage%');
        },
      );
    } catch (error) {
      await api.cancelBuild(ticket.build.id);
      rethrow;
    }
  }

  /// Polls until the build stops processing.
  ///
  /// This is the wait the whole product is built around: nothing is installable
  /// before the server has opened the artifact and read it, and a pipeline that
  /// reports success before this has reported that a file was transferred.
  Future<ImpaktfullAppstoreBuild> _waitForProcessing({
    required ImpaktfullAppstoreApi api,
    required String buildId,
    required Duration timeout,
  }) async {
    final deadline = DateTime.now().add(timeout);
    var build = await api.getBuild(buildId);

    while (build.isProcessing && DateTime.now().isBefore(deadline)) {
      ImpaktfullCliLogger.startSpinner('Processing the build');
      await Future<void>.delayed(const Duration(seconds: 3));
      build = await api.getBuild(buildId);
    }

    if (build.isFailed) {
      // The server's own sentence, which names the artifact's actual problem:
      // a missing provisioning profile, a debuggable release, a corrupt zip.
      throw ImpaktfullCliError(
        'The build was rejected: ${build.failure ?? 'no reason given'}',
      );
    }
    if (build.isProcessing) {
      throw ImpaktfullCliError(
        'The build is still processing after ${timeout.inMinutes} minutes. '
        'It has not been lost; open ${build.url ?? buildId} to follow it.',
      );
    }
    return build;
  }

  ImpaktfullAppstoreEnvironment _resolveEnvironment(
    ImpaktfullAppstoreApp app,
    String environmentName,
  ) {
    final wanted = environmentName.trim().toLowerCase();
    for (final environment in app.environments) {
      if (environment.name == wanted) return environment;
    }
    // The names the key MAY use, which is the useful half of this message: the
    // environment may exist and simply not be in this key's scope, and the
    // answer to both is the same list.
    final available = app.environments.map((e) => e.name).join(', ');
    throw ImpaktfullCliError(
      '`$environmentName` is not an environment this upload key can write to. '
      '${available.isEmpty ? 'This key has no environments in scope.' : 'Available: $available'}',
    );
  }

  void _validateExtension(File file) {
    final fileExtension =
        extension(file.path).replaceAll('.', '').toLowerCase();
    if (fileExtension == 'aab') {
      // Its OWN message. An Android App Bundle is not installable on a device
      // at all, it is what goes to Google Play, and somebody who built one has
      // not made a typo so much as reached for the wrong artifact of a build
      // that produced both.
      throw ImpaktfullCliError(
        'App bundles (.aab) cannot be installed on a device. Build a universal '
        'APK and upload that instead.',
      );
    }
    if (!allowedExtensions.contains(fileExtension)) {
      throw ImpaktfullCliError(
        '`$fileExtension` cannot be uploaded to the impaktfull appstore. '
        'Allowed extensions are: $allowedExtensions',
      );
    }
  }

  /// An `.ipa` into an Android environment is caught HERE as well as by the
  /// server, because the server catches it after the request and this catches
  /// it before the transfer.
  void _validateExtensionMatchesPlatform(
    File file,
    ImpaktfullAppstoreEnvironment environment,
  ) {
    final fileExtension =
        extension(file.path).replaceAll('.', '').toLowerCase();
    final expected = environment.platform == 'ios' ? 'ipa' : 'apk';
    if (fileExtension != expected) {
      throw ImpaktfullCliError(
        '${environment.label} takes a .$expected, and `${basename(file.path)}` '
        'is a .$fileExtension',
      );
    }
  }
}
