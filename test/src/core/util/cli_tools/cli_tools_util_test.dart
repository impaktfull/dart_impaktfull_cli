import 'package:impaktfull_cli/src/core/util/cli_tools/cli_tools_util.dart';
import 'package:test/test.dart';

void main() {
  group('CliToolsUtil.parseToolPath', () {
    test('returns the path printed by `which`', () {
      expect(
        CliToolsUtil.parseToolPath('/opt/flutter/bin/flutter'),
        '/opt/flutter/bin/flutter',
      );
    });

    test('returns the first match printed by `where`', () {
      expect(
        CliToolsUtil.parseToolPath(
          'C:\\flutter\\bin\\flutter\r\nC:\\flutter\\bin\\flutter.bat\r\n',
        ),
        'C:\\flutter\\bin\\flutter',
      );
    });

    test('returns null when nothing is printed', () {
      expect(CliToolsUtil.parseToolPath(''), isNull);
      expect(CliToolsUtil.parseToolPath('\n'), isNull);
    });
  });
}
