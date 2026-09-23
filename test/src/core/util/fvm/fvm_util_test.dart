import 'dart:io';

import 'package:impaktfull_cli/src/core/util/fvm/fvm_util.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  group('FvmUtil', () {
    late Directory tempDir;

    setUp(() => tempDir = Directory.systemTemp.createTempSync('fvm_util_test'));
    tearDown(() => tempDir.deleteSync(recursive: true));

    test('isFvmProject', () async {
      final isFvmProject = await FvmUtil.isFvmProject(Directory.current);
      expect(isFvmProject, isFalse);
    });

    test('finds the .fvmrc of a parent directory', () {
      File(join(tempDir.path, '.fvmrc')).writeAsStringSync('{}');
      final child = Directory(join(tempDir.path, 'packages', 'app'))
        ..createSync(recursive: true);
      expect(
        FvmUtil.findConfigFile(child)?.path,
        join(tempDir.path, '.fvmrc'),
      );
    });

    test('reads the version from .fvmrc', () {
      final file = File(join(tempDir.path, '.fvmrc'))
        ..writeAsStringSync('{"flutter": "3.41.9", "flavors": {}}');
      expect(FvmUtil.getFlutterVersion(file), '3.41.9');
    });

    test('reads the version from the old fvm_config.json', () {
      final file = File(join(tempDir.path, 'fvm_config.json'))
        ..writeAsStringSync('{"flutterSdkVersion": "3.32.8"}');
      expect(FvmUtil.getFlutterVersion(file), '3.32.8');
    });

    test('returns null for an invalid config', () {
      final file = File(join(tempDir.path, '.fvmrc'))
        ..writeAsStringSync('not json');
      expect(FvmUtil.getFlutterVersion(file), isNull);
    });
  });

  group('FvmUtil.matchesFlutterVersion', () {
    bool matches(String fvmVersion) => FvmUtil.matchesFlutterVersion(
      fvmVersion,
      frameworkVersion: '3.41.9',
      channel: 'stable',
      frameworkRevision: 'abcdef1234567890',
    );

    test('a version', () {
      expect(matches('3.41.9'), isTrue);
      expect(matches('v3.41.9'), isTrue);
      expect(matches('3.44.0'), isFalse);
    });

    test('a version on a channel', () {
      expect(matches('3.41.9@stable'), isTrue);
      expect(matches('3.41.9@beta'), isFalse);
    });

    test('a channel', () {
      expect(matches('stable'), isTrue);
      expect(matches('beta'), isFalse);
    });

    test('a commit', () {
      expect(matches('abcdef1'), isTrue);
      expect(matches('1234567'), isFalse);
    });
  });
}
