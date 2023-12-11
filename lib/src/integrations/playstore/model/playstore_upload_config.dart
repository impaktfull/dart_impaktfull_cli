import 'dart:io';

class PlayStoreUploadConfig {
  /// service account credentials file
  /// defaults to:
  ///   1: file located at `android/playstore_credentials.json`
  ///   2: env variable value of `GOOGLE_SERVICE_ACCOUNT_JSON_RAW`
  final File? serviceAccountCredentialsFile;

  const PlayStoreUploadConfig({
    this.serviceAccountCredentialsFile,
  });
}
