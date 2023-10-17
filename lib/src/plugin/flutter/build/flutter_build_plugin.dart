import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/model/data/build/android_build_extension.dart';
import 'package:impaktfull_cli/src/model/data/build/ios_build_extension.dart';
import 'package:impaktfull_cli/src/plugin/cli_plugin.dart';
import 'package:impaktfull_cli/src/util/extensions/iterable_extensions.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' as path;

class FlutterBuildPlugin extends ImpaktfullCliPlugin {
  const FlutterBuildPlugin({
    super.processRunner,
  });

  Future<File> buildAndroid({
    String? flavor,
    String? mainDartFile = 'lib/main.dart',
    AndroidBuildExtension extension = AndroidBuildExtension.abb,
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
    final file = File(join(
        'build',
        'app',
        'outputs',
        extension.flutterBuildArgument,
        flavor,
        'release',
        'app-$flavor-release.${extension.fileExtension}'));
    if (!file.existsSync()) {
      throw ImpaktfullCliError(
          'After building $flavor for iOS, ${file.path} does not exists.');
    }
    return file;
  }

  Future<File> buildIos({
    String? flavor,
    String? mainDartFile = 'lib/main.dart',
    IosBuildExtension extension = IosBuildExtension.ipa,
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
    final buildDirectory = Directory(join('build', 'ios', 'ipa'));
    final files = buildDirectory.listSync();
    final result = files.find(
        (element) => path.extension(element.path) == extension.fileExtension);
    if (result == null) {
      throw ImpaktfullCliError(
          'After building $flavor for iOS, ${buildDirectory.path} does not contain an ${extension.fileExtension} file.');
    }
    final ipaFile = File(result.path);
    if (!ipaFile.existsSync()) {
      throw ImpaktfullCliError(
          'After building $flavor for iOS, ${ipaFile.path} does not exists.');
    }
    return ipaFile;
  }
}
