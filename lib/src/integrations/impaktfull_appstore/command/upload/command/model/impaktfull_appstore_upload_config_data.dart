import 'dart:io';

import 'package:impaktfull_cli/src/core/command/config/command_config.dart';

class ImpaktfullAppstoreUploadConfigData extends ConfigData {
  final File file;
  final String environmentName;
  final Uri baseUrl;
  final String? releaseNotes;
  final bool waitForProcessing;

  const ImpaktfullAppstoreUploadConfigData({
    required this.file,
    required this.environmentName,
    required this.baseUrl,
    required this.releaseNotes,
    required this.waitForProcessing,
  });
}
