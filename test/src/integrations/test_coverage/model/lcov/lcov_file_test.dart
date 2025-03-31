import 'package:impaktfull_cli/src/integrations/test_coverage/model/lcov/lcov_file.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/util/test_coverage_ignore_util.dart';
import 'package:test/test.dart';

void main() {
  test('Lcov parser', () {
    final lcovFile = LcovFile.fromString('''
SF:/Users/impaktfull/work/server/lib/src/di/injectable.dart
DA:14,1
LF:1
LH:1
end_of_record
      ''');
    expect(lcovFile.sources.length, 1);
    expect(lcovFile.amountOfLines, 1);
    expect(lcovFile.amountOfLinesCovered, 1);
    expect(lcovFile.percentage, 1);
  });

  test('Lcov parser with ignore', () {
    final lcovFile = LcovFile.fromString('''
SF:/Users/impaktfull/work/server/lib/src/di/injectable.dart
DA:14,1
LF:1
LH:1
end_of_record
SF:/Users/impaktfull/work/server/lib/src/di/injectable.config.dart
DA:14,0
LF:1
LH:0
end_of_record
SF:/Users/impaktfull/work/server/lib/src/model/person.dart
DA:14,1
LF:1
LH:1
end_of_record
SF:/Users/impaktfull/work/server/lib/src/model/person.g.dart
DA:14,0
LF:1
LH:0
end_of_record
SF:/Users/impaktfull/work/server/lib/src/navigator/main_navigator.dart
DA:14,1
LF:1
LH:1
end_of_record
SF:/Users/impaktfull/work/server/lib/src/navigator/main_navigator.navigator.dart
DA:14,0
LF:1
LH:0
end_of_record
SF:/Users/impaktfull/work/server/lib/src/generated/protocol.dart
DA:14,0
LF:1
LH:0
end_of_record
SF:/Users/impaktfull/work/server/lib/src/generated/protocol.dart
DA:14,0
LF:1
LH:0
end_of_record
SF:/Users/impaktfull/work/server/lib/src/generated/serverpod/model/api/create_user_request.dart
DA:14,1
LF:1
LH:1
end_of_record
SF:/Users/impaktfull/work/server/lib/src/generated/serverpod/root_api_request.dart
DA:14,1
LF:1
LH:1
end_of_record''');
    expect(lcovFile.sources.length, 10);
    expect(lcovFile.amountOfLines, 10);
    expect(lcovFile.amountOfLinesCovered, 5);
    expect(lcovFile.percentage, 0.5);
    final ignored = lcovFile.ignorePatterns(
      TestCoverageIgnoreUtil.defaultIgnorePatterns,
    );
    expect(ignored.sources.length, 3);
    expect(ignored.amountOfLines, 3);
    expect(ignored.amountOfLinesCovered, 3);
    expect(ignored.percentage, 1);
  });
}
