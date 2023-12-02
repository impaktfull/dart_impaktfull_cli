import 'dart:io';

class PlayStoreUploadConfig {
  /// service account credentials file
  /// defaults to env variable value of `GOOGLE_SERVICE_ACCOUNT_JSON_RAW`
  final File? serviceAccountCredentialsFile;

  const PlayStoreUploadConfig({
    this.serviceAccountCredentialsFile,
  });
}
