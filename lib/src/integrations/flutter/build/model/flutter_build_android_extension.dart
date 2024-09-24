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
    final List<String> parts;
    switch (this) {
      case FlutterBuildAndroidExtension.apk:
        parts = [
          'build',
          'app',
          'outputs',
          'apk',
          if (flavor != null) flavor,
          'release',
        ];
      case FlutterBuildAndroidExtension.aab:
        parts = [
          'build',
          'app',
          'outputs',
          'bundle',
          if (flavor == null) ...[
            'release',
          ] else ...[
            '${flavor}Release',
          ]
        ];
    }
    return Directory(joinAll(parts));
  }
}
