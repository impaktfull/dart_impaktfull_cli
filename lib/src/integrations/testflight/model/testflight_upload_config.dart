import 'package:impaktfull_cli/src/core/model/data/secret.dart';

class TestflightUploadConfig {
  /// username/email to login to appstoreconnect
  /// defaults to env variable value of `APPLE_EMAIL`
  final String? userName;

  /// appSpecificPassword to login to appstoreconnect
  /// defaults to env variable value of `APPLE_APP_SPECIFIC_PASSWORD`
  final Secret? appSpecificPassword;

  /// type of the app to upload
  /// default: `ios`
  final String type;

  const TestflightUploadConfig({
    this.userName,
    this.appSpecificPassword,
    this.type = 'ios',
  });
}
