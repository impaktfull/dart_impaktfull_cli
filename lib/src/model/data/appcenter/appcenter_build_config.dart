import 'dart:io';

import 'package:impaktfull_cli/src/model/data/secret.dart';

class AppCenterBuildConfig {
  final String appName;
  final File file;
  final String? ownerName;
  final Secret? apiToken;
  final List<String> distributionGroups;
  final bool notifyListeners;

  const AppCenterBuildConfig({
    required this.appName,
    required this.file,
    this.ownerName,
    this.apiToken,
    this.distributionGroups = const [],
    this.notifyListeners = false,
  });
}
