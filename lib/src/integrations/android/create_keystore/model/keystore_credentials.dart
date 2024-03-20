import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';

class KeyStoreCredentials {
  final String name;
  final File storeFile;
  final String keyAlias;
  final Secret password;

  final String? dNameFullName;
  final String? dNameOrganization;
  final String? dNameOrganizationUnit;
  final String? dNameCity;
  final String? dNameState;
  final String? dNameCountry;

  KeyStoreCredentials({
    required this.name,
    required this.storeFile,
    required this.keyAlias,
    required this.password,
    required this.dNameFullName,
    required this.dNameOrganization,
    required this.dNameOrganizationUnit,
    required this.dNameCity,
    required this.dNameState,
    required this.dNameCountry,
  });

  String? get dName {
    final dNameItems = [
      dNameFullName == null ? null : "cn=$dNameFullName",
      dNameOrganization == null ? null : "o=$dNameOrganization",
      dNameOrganizationUnit == null ? null : "ou=$dNameOrganizationUnit",
      dNameCity == null ? null : "l=$dNameCity",
      dNameState == null ? null : "st=$dNameState",
      dNameCountry == null ? null : "c=$dNameCountry",
    ].whereType<String>();
    if (dNameItems.isEmpty) return null;
    return dNameItems.join(', ');
  }
}
