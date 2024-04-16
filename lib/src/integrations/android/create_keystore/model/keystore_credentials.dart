import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';

class KeyStoreCredentials {
  final String name;
  final File storeFile;
  final String keyAlias;
  final Secret password;

  final String? fullName;
  final String? organization;
  final String? organizationUnit;
  final String? city;
  final String? state;
  final String? country;

  KeyStoreCredentials({
    required this.name,
    required this.storeFile,
    required this.keyAlias,
    required this.password,
    required this.fullName,
    required this.organization,
    required this.organizationUnit,
    required this.city,
    required this.state,
    required this.country,
  });

  String? get dName {
    final dNameItems = [
      fullName == null ? null : "cn=$fullName",
      organization == null ? null : "o=$organization",
      organizationUnit == null ? null : "ou=$organizationUnit",
      city == null ? null : "l=$city",
      state == null ? null : "st=$state",
      country == null ? null : "c=$country",
    ].whereType<String>();
    if (dNameItems.isEmpty) return null;
    return dNameItems.join(', ');
  }
}
