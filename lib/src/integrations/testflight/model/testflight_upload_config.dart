import 'package:impaktfull_cli/src/integrations/testflight/model/testflight_credentials.dart';

class TestFlightUploadConfig {
  /// credentials to login to appstoreconnect
  final TestFlightCredentials? credentials;

  /// type of the app to upload
  /// default: `ios`
  final String type;

  const TestFlightUploadConfig({
    this.credentials,
    this.type = 'ios',
  });
}
