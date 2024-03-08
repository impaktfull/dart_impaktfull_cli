import 'dart:io';

import 'package:path/path.dart';

class CliConstants {
  CliConstants._();

  static final buildFolder = Directory(join('build', 'impaktfull_cli'));

  static String get buildFolderPath => buildFolder.path;
}
