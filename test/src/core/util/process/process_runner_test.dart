import 'dart:io';

import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_process_runner_error.dart';
import 'package:impaktfull_cli/src/core/util/process/process_runner.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  const processRunner = CliProcessRunner();
  final dart = Platform.resolvedExecutable;
  late Directory tempDir;
  late String script;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('process_runner_test');
    script = join(tempDir.path, 'script.dart');
    File(script).writeAsStringSync(r'''
import 'dart:io';

void main(List<String> args) {
  switch (args.first) {
    case 'big':
      // Far larger than one stdout chunk, with multi-byte characters that
      // end up split over chunk boundaries.
      for (var i = 0; i < 20000; i++) {
        stdout.writeln('line $i ✅ héllo');
      }
    case 'exit':
      stderr.writeln('something failed');
      exit(3);
  }
}
''');
  });

  tearDownAll(() => tempDir.deleteSync(recursive: true));

  group('CliProcessRunner', () {
    test('never loses the output of processes that run in parallel', () async {
      for (var i = 0; i < 10; i++) {
        final results = await List.generate(
          16,
          (_) => processRunner.runProcess([dart, '--version']),
        ).wait;
        for (final result in results) {
          expect(result, contains('Dart SDK version'));
        }
      }
    });

    test('returns large output unchanged', () async {
      final result = await processRunner.runProcess([dart, script, 'big']);
      final lines = result.split('\n');
      expect(lines, hasLength(20000));
      for (var i = 0; i < lines.length; i++) {
        expect(lines[i], 'line $i ✅ héllo');
      }
    });

    test('throws with the output when the process fails', () async {
      expect(
        () => processRunner.runProcess([dart, script, 'exit']),
        throwsA(
          isA<ImpaktfullCliProcessRunnerError>().having(
            (e) => e.errorOutput,
            'errorOutput',
            contains('something failed'),
          ),
        ),
      );
    });

    test('finds executables in the paths added to PATH', () async {
      final binDir = Directory(join(tempDir.path, 'bin'))..createSync();
      if (Platform.isWindows) {
        File(
          join(binDir.path, 'impaktfull_fake_tool.bat'),
        ).writeAsStringSync('@echo fake tool\r\n');
      } else {
        final tool = File(join(binDir.path, 'impaktfull_fake_tool'))
          ..writeAsStringSync('#!/bin/sh\necho fake tool\n');
        await Process.run('chmod', ['+x', tool.path]);
      }
      ProcessRunner.updatePath(pathsToAdd: [binDir.path]);

      final result = await processRunner.runProcess(['impaktfull_fake_tool']);
      expect(result, 'fake tool');
    });
  });

  group('ProcessRunner.buildPath', () {
    test('appends the paths with `:` on macOS and Linux', () {
      final path = ProcessRunner.buildPath(
        currentPath: '/usr/bin',
        home: '/home/ci',
        pathsToAdd: [r'$HOME/.pub-cache/bin', '/opt/flutter/bin'],
        isWindows: false,
      );
      expect(path, '/usr/bin:/home/ci/.pub-cache/bin:/opt/flutter/bin');
    });

    test('appends the paths with `;` on Windows', () {
      final path = ProcessRunner.buildPath(
        currentPath: r'C:\Windows',
        home: r'C:\Users\ci',
        pathsToAdd: [r'$HOME\fvm\default\bin'],
        isWindows: true,
      );
      expect(path, r'C:\Windows;C:\Users\ci\fvm\default\bin');
    });

    test('works without a PATH or HOME', () {
      final path = ProcessRunner.buildPath(
        currentPath: null,
        home: null,
        pathsToAdd: ['/opt/flutter/bin'],
        isWindows: false,
      );
      expect(path, '/opt/flutter/bin');
    });
  });
}
