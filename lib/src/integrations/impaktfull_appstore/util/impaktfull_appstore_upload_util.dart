import 'dart:io';

import 'package:meta/meta.dart';

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
      final environment = _resolveEnvironment(
        app,
        config.environmentName,
        file,
      );
      ImpaktfullCliLogger.verbose(
        'Uploading to ${app.name} (${environment.label}, '
        '${environment.appIdentifier})',
      );

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

      // AWAITED, both of them. `finally` disposes the http client, and a
      // future returned without awaiting would have that run first: the client
      // closes while the request it is running is still in flight.
      if (!config.waitForProcessing) {
        return await api.getBuild(ticket.build.id);
      }
      return await _waitForProcessing(
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

  /// Exposed for tests. The resolution rule is worth pinning directly: it is
  /// two lines that decide which environment a release lands in.
  @visibleForTesting
  ImpaktfullAppstoreEnvironment debugResolveEnvironment(
    ImpaktfullAppstoreApp app,
    String environmentName,
    File file,
  ) =>
      _resolveEnvironment(app, environmentName, file);

  /// The environment named [environmentName] FOR THIS FILE'S PLATFORM.
  ///
  /// Both halves matter. An app almost always has the same environment name on
  /// both platforms, `alpha` on iOS and `alpha` on Android, and matching on the
  /// name alone picks whichever was returned first: an `.apk` then resolves to
  /// the iOS environment and the upload fails for a reason that has nothing to
  /// do with what went wrong. The server derives the platform from the
  /// extension for exactly this reason; this matches it.
  ImpaktfullAppstoreEnvironment _resolveEnvironment(
    ImpaktfullAppstoreApp app,
    String environmentName,
    File file,
  ) {
    final wanted = environmentName.trim().toLowerCase();
    final platform = _platformOf(file);

    for (final environment in app.environments) {
      if (environment.name == wanted && environment.platform == platform) {
        return environment;
      }
    }

    // The name exists, on the other platform. Worth saying, because it is the
    // likeliest mistake: the right name and the wrong artifact.
    final otherPlatform = app.environments.any((e) => e.name == wanted);
    if (otherPlatform) {
      throw ImpaktfullCliError(
        '`$environmentName` exists but not for $platform, and '
        '`${basename(file.path)}` is a $platform build.',
      );
    }

    // Otherwise the names this key MAY use, which is the useful half: the
    // environment can exist and simply not be in this key's scope.
    final available = app.environments
        .where((e) => e.platform == platform)
        .map((e) => e.name)
        .join(', ');
    throw ImpaktfullCliError(
      '`$environmentName` is not a $platform environment this upload key can '
      'write to. ${available.isEmpty ? 'This key has no $platform environments in scope.' : 'Available: $available'}',
    );
  }

  /// `ios` or `android`, from the extension, exactly as the server decides it.
  String _platformOf(File file) =>
      extension(file.path).toLowerCase() == '.ipa' ? 'ios' : 'android';

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
}
