import 'dart:io';

import 'package:path/path.dart';

class FvmUtil {
  const FvmUtil._();
  static Future<bool> isFvmProject(Directory workingDir) async {
    final fvmrcFile = File(join(workingDir.path, '.fvmrc'));
    if (fvmrcFile.existsSync()) {
      return true;
    }
    // fvm_config.json is the old config file
    final fvmConfigFile = File(join(workingDir.path, 'fvm', 'fvm_config.json'));
    if (fvmConfigFile.existsSync()) {
      return true;
    }
    return isFvmProject(workingDir.parent);
  }
}
