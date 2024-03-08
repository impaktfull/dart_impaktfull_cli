import 'dart:io';

class PlayStoreUploadConfig {
  /// service account credentials file
  /// defaults to:
  ///   1: file located at `android/playstore_credentials.json`
  ///   2: env variable value of `GOOGLE_SERVICE_ACCOUNT_JSON_RAW`
  final File? serviceAccountCredentialsFile;
  final PlaystoreTrackType trackType;
  final PlaystoreReleaseStatus releaseStatus;

  const PlayStoreUploadConfig({
    this.serviceAccountCredentialsFile,
    this.trackType = PlaystoreTrackType.internal,
    this.releaseStatus = PlaystoreReleaseStatus.draft,
  });
}

enum PlaystoreTrackType {
  internal('internal');

  final String value;

  const PlaystoreTrackType(
    this.value,
  );
}

enum PlaystoreReleaseStatus {
  completed('completed'),
  draft('draft');

  final String value;
  const PlaystoreReleaseStatus(
    this.value,
  );
}
