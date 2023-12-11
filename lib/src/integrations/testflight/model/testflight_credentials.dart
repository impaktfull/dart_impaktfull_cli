import 'package:impaktfull_cli/src/core/model/data/secret.dart';

class TestFlightCredentials {
  /// username/email to login to appstoreconnect
  /// defaults to env variable value of `APPLE_EMAIL`
  final String? userName;

  /// appSpecificPassword to login to appstoreconnect
  /// defaults to env variable value of `APPLE_APP_SPECIFIC_PASSWORD`
  final Secret? appSpecificPassword;

  const TestFlightCredentials({
    this.userName,
    this.appSpecificPassword,
  });
}
