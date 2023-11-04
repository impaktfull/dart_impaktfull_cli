import 'dart:io';

import 'package:path/path.dart';

enum FlutterBuildAndroidExtension {
  apk('apk', 'apk'),
  aab('appbundle', 'aab');

  final String flutterBuildArgument;
  final String fileExtension;

  const FlutterBuildAndroidExtension(
    this.flutterBuildArgument,
    this.fileExtension,
  );
}

extension FlutterBuildAndroidExtensions on FlutterBuildAndroidExtension {
  Directory getBuildDirectory({String? flavor}) {
    switch (this) {
      case FlutterBuildAndroidExtension.apk:
        return Directory(
            join('build', 'app', 'outputs', 'apk', flavor, 'release'));
      case FlutterBuildAndroidExtension.aab:
        return Directory(
            join('build', 'app', 'outputs', 'bundle', '${flavor}Release'));
    }
  }
}
