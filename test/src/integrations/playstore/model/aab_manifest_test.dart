import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/integrations/playstore/model/aab_manifest.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  // The manifest of a real bundle, built with
  // `flutter build appbundle --build-name=1.2.3 --build-number=42`.
  final manifestFixture = File(
    'test/fixtures/aab/AndroidManifest.pb',
  ).readAsBytesSync();

  group('AabManifest', () {
    test('reads a manifest from a real Flutter build', () {
      final manifest = AabManifest.fromProto(manifestFixture);
      expect(manifest.packageName, 'com.example.e2e_app');
      expect(manifest.versionCode, 42);
      expect(manifest.versionName, '1.2.3');
    });

    test('reads the manifest from an .aab file', () {
      final tempDir = Directory.systemTemp.createTempSync('aab_manifest_test');
      addTearDown(() => tempDir.deleteSync(recursive: true));
      final archive = Archive()
        ..add(ArchiveFile.bytes('base/dex/classes.dex', [0, 1, 2]))
        ..add(
          ArchiveFile.bytes(
            'base/manifest/AndroidManifest.xml',
            manifestFixture,
          ),
        );
      final aab = File(join(tempDir.path, 'app-release.aab'))
        ..writeAsBytesSync(ZipEncoder().encodeBytes(archive));

      final manifest = AabManifest.fromFile(aab);
      expect(manifest.packageName, 'com.example.e2e_app');
      expect(manifest.versionCode, 42);
    });

    test('falls back to the compiled versionCode without a raw value', () {
      final manifest = AabManifest.fromProto(
        _manifest([
          _attribute('package', 'com.example.app'),
          _attribute('versionCode', null, compiledInt: 7),
        ]),
      );
      expect(manifest.versionCode, 7);
      expect(manifest.versionName, isNull);
    });

    test('throws when the package name is missing', () {
      expect(
        () => AabManifest.fromProto(
          _manifest([_attribute('versionCode', '1')]),
        ),
        throwsA(isA<ImpaktfullCliError>()),
      );
    });

    test('throws for a file that is not an app bundle', () {
      final tempDir = Directory.systemTemp.createTempSync('aab_manifest_test');
      addTearDown(() => tempDir.deleteSync(recursive: true));
      final archive = Archive()
        ..add(ArchiveFile.bytes('AndroidManifest.xml', [0, 1, 2]));
      final apk = File(join(tempDir.path, 'app-release.aab'))
        ..writeAsBytesSync(ZipEncoder().encodeBytes(archive));
      expect(
        () => AabManifest.fromFile(apk),
        throwsA(isA<ImpaktfullCliError>()),
      );
    });
  });
}

// A minimal protobuf encoder for the few messages of aapt2's Resources.proto
// the tests need.
Uint8List _manifest(List<List<int>> attributes) {
  final element = [
    ..._string(3, 'manifest'),
    for (final attribute in attributes) ..._bytes(4, attribute),
  ];
  return Uint8List.fromList(_bytes(1, element));
}

List<int> _attribute(String name, String? value, {int? compiledInt}) => [
  ..._string(2, name),
  if (value != null) ..._string(3, value),
  if (compiledInt != null)
    // compiled_item > prim > int_decimal_value
    ..._bytes(
      6,
      _bytes(7, [..._varint((6 << 3) | 0), ..._varint(compiledInt)]),
    ),
];

List<int> _string(int field, String value) => _bytes(field, utf8.encode(value));

List<int> _bytes(int field, List<int> value) => [
  ..._varint((field << 3) | 2),
  ..._varint(value.length),
  ...value,
];

List<int> _varint(int value) {
  final bytes = <int>[];
  while (value >= 0x80) {
    bytes.add((value & 0x7f) | 0x80);
    value >>= 7;
  }
  bytes.add(value);
  return bytes;
}
