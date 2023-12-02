import 'package:impaktfull_cli/src/core/model/data/secret.dart';

class TestflightUploadConfig {
  final String userName;
  final Secret appSpecificPassword;
  final String type;

  const TestflightUploadConfig({
    required this.userName,
    required this.appSpecificPassword,
    this.type = 'ios',
  });
}
