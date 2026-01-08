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
  Directory getBuildDirectory({
    String? flavor,
    bool androidSplitPath = false,
  }) {
    final List<String> parts;
    switch (this) {
      case FlutterBuildAndroidExtension.apk:
        if (androidSplitPath) {
          parts = [
            'build',
            'app',
            'outputs',
            'apk',
            if (flavor != null) flavor,
            'release',
          ];
        } else {
          parts = [
            'build',
            'app',
            'outputs',
            'flutter-apk',
          ];
        }
        break;
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
        break;
    }
    return Directory(joinAll(parts));
  }
}
