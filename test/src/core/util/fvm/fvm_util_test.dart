import 'dart:io';

import 'package:impaktfull_cli/src/core/util/fvm/fvm_util.dart';
import 'package:test/test.dart';

void main() {
  group('FvmUtil', () {
    test('isFvmProject', () async {
      final isFvmProject = await FvmUtil.isFvmProject(Directory.current);
      expect(isFvmProject, isFalse);
    });
  });
}
