import 'package:impaktfull_cli/src/core/util/flutter/flutter_command.dart';
import 'package:test/test.dart';

void main() {
  group('FlutterVersion.parse', () {
    const machineOutput = '''
{
  "frameworkVersion": "3.41.9",
  "channel": "stable",
  "repositoryUrl": "https://github.com/flutter/flutter.git",
  "frameworkRevision": "abcdef1234567890",
  "dartSdkVersion": "3.11.5",
  "flutterRoot": "/opt/flutter"
}''';

    test('parses `flutter --version --machine`', () {
      final version = FlutterVersion.parse(machineOutput);
      expect(version.frameworkVersion, '3.41.9');
      expect(version.channel, 'stable');
      expect(version.frameworkRevision, 'abcdef1234567890');
      expect(version.toString(), 'Flutter 3.41.9 (stable) at /opt/flutter');
    });

    test('ignores output before the JSON', () {
      final version = FlutterVersion.parse(
        'Welcome to Flutter! https://flutter.dev\n$machineOutput',
      );
      expect(version.frameworkVersion, '3.41.9');
    });

    test('throws without JSON', () {
      expect(
        () => FlutterVersion.parse('flutter: command not found'),
        throwsFormatException,
      );
    });
  });
}
