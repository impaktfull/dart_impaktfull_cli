import 'dart:io';

import 'package:path/path.dart';

enum AndroidBuildExtension {
  apk('apk', 'apk'),
  aab('appbundle', 'aab');

  final String flutterBuildArgument;
  final String fileExtension;

  const AndroidBuildExtension(
    this.flutterBuildArgument,
    this.fileExtension,
  );
}

extension AndroidBuildExtensions on AndroidBuildExtension {
  Directory getBuildDirectory({String? flavor}) {
    switch (this) {
      case AndroidBuildExtension.apk:
        return Directory(
            join('build', 'app', 'outputs', 'apk', flavor, 'release'));
      case AndroidBuildExtension.aab:
        return Directory(
            join('build', 'app', 'outputs', 'bundle', '${flavor}Release'));
    }
  }
}
