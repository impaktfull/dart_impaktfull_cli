import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';

class ParsedConfigData implements ImpaktfullCliConfigData {
  @override
  final String androidPackageNameAlpha;

  @override
  final String androidPackageNameBeta;

  @override
  final String androidPackageNameDev;

  @override
  final String androidPackageNameProd;

  @override
  final String iosPackageNameAlpha;

  @override
  final String iosPackageNameBeta;

  @override
  final String iosPackageNameDev;

  @override
  final String iosPackageNameProd;

  ParsedConfigData._({
    required this.androidPackageNameAlpha,
    required this.androidPackageNameBeta,
    required this.androidPackageNameDev,
    required this.androidPackageNameProd,
    required this.iosPackageNameAlpha,
    required this.iosPackageNameBeta,
    required this.iosPackageNameDev,
    required this.iosPackageNameProd,
  });
  factory ParsedConfigData.parse(File file) {
    final fileContent = file.readAsStringSync();
    return ParsedConfigData._(
      androidPackageNameAlpha:
          getStringValue(fileContent, 'androidPackageNameAlpha'),
      androidPackageNameBeta:
          getStringValue(fileContent, 'androidPackageNameBeta'),
      androidPackageNameDev:
          getStringValue(fileContent, 'androidPackageNameDev'),
      androidPackageNameProd:
          getStringValue(fileContent, 'androidPackageNameProd'),
      iosPackageNameAlpha: getStringValue(fileContent, 'iosPackageNameAlpha'),
      iosPackageNameBeta: getStringValue(fileContent, 'iosPackageNameBeta'),
      iosPackageNameDev: getStringValue(fileContent, 'iosPackageNameDev'),
      iosPackageNameProd: getStringValue(fileContent, 'iosPackageNameProd'),
    );
  }

  static String getStringValue(String fileContent, String key) {
    final regex = RegExp(
        // ignore: prefer_interpolation_to_compose_strings
        r'''String get.*''' + key + '''.*\n*.*=>.*\n*.*['"](.*)['"].*\n*.*;''');
    final match = regex.firstMatch(fileContent);
    final value = match?.group(1);
    if (value == null) {
      throw ArgumentError('Could not parse $key in config file');
    }
    return value;
  }
}
