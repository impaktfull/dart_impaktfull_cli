import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/integrations/android/create_keystore/model/keystore_credentials.dart';
import 'package:path/path.dart';

class AndroidProject {
  final Directory directory;

  File get gradleFile => File(join('android', 'app', 'build.gradle'));

  AndroidProject(this.directory);

  void validate() {
    _checkIfGradleFileExits();
  }

  void _checkIfGradleFileExits() {
    if (!gradleFile.existsSync()) {
      throw ImpaktfullCliError(
          '${gradleFile.path} does not exist. Maybe your android project is corrupt');
    }
  }

  void replacePackageName(String newPackageName) {
    var content = gradleFile.readAsStringSync();
    content = content.replaceAll(
        RegExp(r'applicationId "[\w.]*"'), 'applicationId "$newPackageName"');
    gradleFile.writeAsStringSync(content);
  }

  void replaceNamespace(String newNameSpace) {
    var content = gradleFile.readAsStringSync();
    content = content.replaceAll(
        RegExp(r'namespace "[\w.]*"'), 'namespace "$newNameSpace"');
    gradleFile.writeAsStringSync(content);
  }

  void replaceSigningConfig({
    required KeyStoreCredentials keyStoreCredentials,
  }) {
    final name = keyStoreCredentials.name;
    var content = gradleFile.readAsStringSync();

    final RegExp configBlockPattern = RegExp(
      r'.*' +
          name +
          r' {\n.*storeFile file\("(.*)"\)\n.*storePassword "(.*)"\n.*keyAlias "(.*)"\n.*keyPassword "(.*)"\n.*}',
      multiLine: true,
    );
    final allMatches = configBlockPattern.allMatches(content);
    final match = allMatches.first.group(0)!;
    final updatedMatch = match
        .replaceFirst(RegExp(r'storePassword "(.*?)"'),
            'storePassword "${keyStoreCredentials.password}"')
        .replaceFirst(RegExp(r'keyAlias "(.*?)"'),
            'keyAlias "${keyStoreCredentials.keyAlias}"')
        .replaceFirst(RegExp(r'keyPassword "(.*?)"'),
            'keyPassword "${keyStoreCredentials.password}"');

    final updatedContent = content.replaceAll(configBlockPattern, updatedMatch);

    if (updatedContent == content) {
      throw ImpaktfullCliError(
          'No matching signing config named "$name" found or no changes necessary.');
    }

    gradleFile.writeAsStringSync(updatedContent);
  }
}
