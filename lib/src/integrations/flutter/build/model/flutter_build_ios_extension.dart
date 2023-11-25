import 'dart:io';

import 'package:path/path.dart';

enum FlutterBuildIosExtension {
  ipa('ipa', 'ipa');

  final String flutterBuildArgument;
  final String fileExtension;

  const FlutterBuildIosExtension(
    this.flutterBuildArgument,
    this.fileExtension,
  );
}

extension FlutterBuildIosExtensions on FlutterBuildIosExtension {
  Directory getBuildDirectory() {
    switch (this) {
      case FlutterBuildIosExtension.ipa:
        return Directory(join('build', 'ios', 'ipa'));
    }
  }
}
