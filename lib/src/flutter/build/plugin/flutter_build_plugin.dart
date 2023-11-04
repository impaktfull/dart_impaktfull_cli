import 'dart:io';

import 'package:impaktfull_cli/src/cli/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/cli/plugin/cli_plugin.dart';
import 'package:impaktfull_cli/src/cli/util/args/env/impaktfull_cli_environment.dart';
import 'package:impaktfull_cli/src/flutter/build/model/flutter_build_android_extension.dart';
import 'package:impaktfull_cli/src/flutter/build/model/flutter_build_ios_extension.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' as path;

class FlutterBuildPlugin extends ImpaktfullCliPlugin {
  const FlutterBuildPlugin({
    super.processRunner,
  });

  Future<File> buildAndroid({
    String? flavor,
    String? mainDartFile = 'lib/main.dart',
    FlutterBuildAndroidExtension extension = FlutterBuildAndroidExtension.aab,
    bool obfuscate = true,
    String? splitDebugInfoPath = 'build/debug-info',
    int? buildNr,
  }) async {
    await processRunner.runProcessVerbose([
      if (ImpaktfullCliEnvironment.useFvmForFlutterBuilds) ...[
        'fvm',
      ],
      'flutter',
      'build',
      extension.flutterBuildArgument,
      '--release',
      if (flavor != null) ...[
        '--flavor=$flavor',
      ],
      if (mainDartFile != null) ...[
        '-t',
        mainDartFile,
      ],
      if (obfuscate) ...[
        'obfuscate',
        if (splitDebugInfoPath != null) ...[
          '--split-debug-info=$splitDebugInfoPath',
        ],
      ],
      if (buildNr != null) ...[
        '--build-number=$buildNr',
      ],
    ]);
    final file = File(join(extension.getBuildDirectory(flavor: flavor).path,
        'app-$flavor-release.${extension.fileExtension}'));
    if (!file.existsSync()) {
      throw ImpaktfullCliError(
          'After building $flavor for Android, `${file.path}` does not exists.');
    }
    return file;
  }

  Future<File> buildIos({
    String? flavor,
    String? mainDartFile = 'lib/main.dart',
    FlutterBuildIosExtension extension = FlutterBuildIosExtension.ipa,
    bool obfuscate = true,
    String? splitDebugInfoPath = '.build/debug-info',
    int? buildNr,
  }) async {
    await processRunner.runProcessVerbose([
      if (ImpaktfullCliEnvironment.useFvmForFlutterBuilds) ...[
        'fvm',
      ],
      'flutter',
      'build',
      extension.flutterBuildArgument,
      '--release',
      if (flavor != null) ...[
        '--flavor=$flavor',
        '--export-options-plist',
        'ios/provisioning/export_options/$flavor.plist',
      ] else ...[
        '--export-options-plist',
        'ios/provisioning/export_options.plist',
      ],
      if (mainDartFile != null) ...[
        '-t',
        mainDartFile,
      ],
      if (obfuscate) ...[
        'obfuscate',
        if (splitDebugInfoPath != null) ...[
          '--split-debug-info=$splitDebugInfoPath',
        ],
      ],
      if (buildNr != null) ...[
        '--build-number=$buildNr',
      ],
    ]);
    final buildDirectory = extension.getBuildDirectory();
    final files = buildDirectory.listSync();
    final result = files.where((element) =>
        path.extension(element.path) == '.${extension.fileExtension}');
    if (result.isEmpty) {
      throw ImpaktfullCliError(
          'After building $flavor for iOS, `${buildDirectory.path}` does not contain an `${extension.fileExtension}` file.');
    }
    if (result.length > 1) {
      throw ImpaktfullCliError(
          'After building $flavor for iOS, Multiple .$extension files were found in `${buildDirectory.path}`. Auto selecting the right one is not yet implemented.');
    }

    final ipaFile = File(result.first.path);
    if (!ipaFile.existsSync()) {
      throw ImpaktfullCliError(
          'After building $flavor for iOS, `${ipaFile.path}` does not exists.');
    }
    return ipaFile;
  }
}
