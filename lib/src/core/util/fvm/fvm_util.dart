import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

class FvmUtil {
  const FvmUtil._();

  static const _channels = ['stable', 'beta', 'dev', 'main', 'master'];

  static Future<bool> isFvmProject(Directory workingDir) async =>
      findConfigFile(workingDir) != null;

  /// The fvm config of [workingDir] or of the closest parent that has one.
  static File? findConfigFile(Directory workingDir) {
    final fvmrcFile = File(join(workingDir.path, '.fvmrc'));
    if (fvmrcFile.existsSync()) {
      return fvmrcFile;
    }
    // fvm_config.json is the old config file
    final fvmConfigFile = File(join(workingDir.path, 'fvm', 'fvm_config.json'));
    if (fvmConfigFile.existsSync()) {
      return fvmConfigFile;
    }
    if (workingDir.parent.path == workingDir.path) {
      return null;
    }
    return findConfigFile(workingDir.parent);
  }

  /// The Flutter version pinned in [configFile]: a version (`3.41.9`), a
  /// version on a channel (`3.41.9@beta`), a channel (`stable`) or a commit.
  static String? getFlutterVersion(File configFile) {
    try {
      final json = jsonDecode(configFile.readAsStringSync());
      if (json is! Map<String, dynamic>) return null;
      // `.fvmrc` uses `flutter`, the old `fvm_config.json` `flutterSdkVersion`.
      final version = json['flutter'] ?? json['flutterSdkVersion'];
      return version is String && version.isNotEmpty ? version : null;
    } on FormatException {
      return null;
    }
  }

  /// Whether the Flutter SDK described by `flutter --version --machine`
  /// is the one [fvmVersion] pins.
  static bool matchesFlutterVersion(
    String fvmVersion, {
    required String frameworkVersion,
    required String channel,
    required String frameworkRevision,
  }) {
    final parts = fvmVersion.split('@');
    final version = parts.first;
    if (parts.length > 1 && parts[1] != channel) return false;
    if (_channels.contains(version)) return version == channel;
    if (RegExp(r'^[0-9a-f]{7,40}$').hasMatch(version)) {
      return frameworkRevision.startsWith(version);
    }
    return version.replaceFirst(RegExp('^v'), '') == frameworkVersion;
  }
}
