import 'package:impaktfull_cli/src/core/model/data/secret.dart';

class TestflightUploadConfig {
  final String? userName;
  final Secret? appSpecificPassword;
  final String type;

  const TestflightUploadConfig({
    this.userName,
    this.appSpecificPassword,
    this.type = 'ios',
  });
}
