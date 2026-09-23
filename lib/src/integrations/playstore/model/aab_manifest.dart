import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:meta/meta.dart';

/// The package name and version of an Android App Bundle (`.aab`).
///
/// Read straight from the bundle, so uploading to the Play Store needs no
/// `bundletool` or `aapt2`, which GitHub-hosted runners do not have on the
/// PATH.
class AabManifest {
  static const _manifestPath = 'base/manifest/AndroidManifest.xml';

  final String packageName;
  final int versionCode;
  final String? versionName;

  const AabManifest({
    required this.packageName,
    required this.versionCode,
    required this.versionName,
  });

  factory AabManifest.fromFile(File file) {
    final input = InputFileStream(file.path);
    try {
      final archive = ZipDecoder().decodeStream(input);
      final manifest = archive.findFile(_manifestPath)?.readBytes();
      if (manifest == null) {
        throw ImpaktfullCliError(
          '`${file.path}` is not an Android App Bundle: $_manifestPath is missing',
        );
      }
      return AabManifest.fromProto(manifest);
    } finally {
      input.closeSync();
    }
  }

  /// Parses the manifest of a bundle module, which aapt2 stores as a protobuf
  /// `XmlNode` (frameworks/base/tools/aapt2/Resources.proto), not as binary
  /// XML like in an APK.
  @visibleForTesting
  factory AabManifest.fromProto(Uint8List bytes) {
    // XmlNode.element = 1
    final element = _ProtoReader(bytes).firstBytes(1);
    if (element == null) {
      throw ImpaktfullCliError('AndroidManifest.xml has no root element');
    }
    String? packageName;
    int? versionCode;
    String? versionName;
    // XmlElement.attribute = 4
    for (final attribute in _ProtoReader(element).allBytes(4)) {
      final reader = _ProtoReader(attribute);
      // XmlAttribute.name = 2, XmlAttribute.value = 3 (the raw value)
      final name = reader.firstString(2);
      final value = reader.firstString(3);
      switch (name) {
        case 'package':
          packageName = value;
        case 'versionCode':
          versionCode = int.tryParse(value ?? '') ?? _compiledInt(attribute);
        case 'versionName':
          versionName = value;
      }
    }
    if (packageName == null || packageName.isEmpty) {
      throw ImpaktfullCliError('Package name not found in AndroidManifest.xml');
    }
    if (versionCode == null) {
      throw ImpaktfullCliError('Version code not found in AndroidManifest.xml');
    }
    return AabManifest(
      packageName: packageName,
      versionCode: versionCode,
      versionName: versionName == null || versionName.isEmpty
          ? null
          : versionName,
    );
  }

  /// XmlAttribute.compiled_item (6) > Item.prim (7) > Primitive
  /// .int_decimal_value (6) or .int_hexadecimal_value (7).
  static int? _compiledInt(Uint8List attribute) {
    final item = _ProtoReader(attribute).firstBytes(6);
    final primitive = item == null ? null : _ProtoReader(item).firstBytes(7);
    if (primitive == null) return null;
    final reader = _ProtoReader(primitive);
    return reader.firstVarint(6) ?? reader.firstVarint(7);
  }
}

/// Reads the fields of one protobuf message. Only what [AabManifest] needs.
class _ProtoReader {
  final Uint8List _bytes;

  const _ProtoReader(this._bytes);

  Uint8List? firstBytes(int field) {
    for (final (number, value) in _fields()) {
      if (number == field && value is Uint8List) return value;
    }
    return null;
  }

  Iterable<Uint8List> allBytes(int field) sync* {
    for (final (number, value) in _fields()) {
      if (number == field && value is Uint8List) yield value;
    }
  }

  String? firstString(int field) {
    final bytes = firstBytes(field);
    return bytes == null ? null : utf8.decode(bytes, allowMalformed: true);
  }

  int? firstVarint(int field) {
    for (final (number, value) in _fields()) {
      if (number == field && value is int) return value;
    }
    return null;
  }

  /// Every field as (field number, value): an [int] for a varint, a
  /// [Uint8List] for a length-delimited field, `null` for fixed-size ones.
  Iterable<(int, Object?)> _fields() sync* {
    var offset = 0;
    int readVarint() {
      var result = 0;
      var shift = 0;
      while (true) {
        if (offset >= _bytes.length) {
          throw const FormatException('Truncated protobuf varint');
        }
        final byte = _bytes[offset++];
        result |= (byte & 0x7f) << shift;
        if (byte & 0x80 == 0) return result;
        shift += 7;
      }
    }

    while (offset < _bytes.length) {
      final key = readVarint();
      final number = key >> 3;
      switch (key & 0x7) {
        case 0:
          yield (number, readVarint());
        case 1:
          offset += 8;
          yield (number, null);
        case 2:
          final length = readVarint();
          if (offset + length > _bytes.length) {
            throw const FormatException('Truncated protobuf field');
          }
          yield (
            number,
            Uint8List.sublistView(_bytes, offset, offset + length),
          );
          offset += length;
        case 5:
          offset += 4;
          yield (number, null);
        default:
          throw FormatException('Unsupported protobuf wire type ${key & 0x7}');
      }
    }
  }
}
