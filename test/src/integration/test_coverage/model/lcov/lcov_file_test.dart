import 'package:impaktfull_cli/src/integrations/test_coverage/model/lcov/lcov_file.dart';
import 'package:test/test.dart';

void main() {
  test('Lcov parser', () {
    final lcovFile = LcovFile.fromString('''
SF:/Users/vanlooverenkoen/work/sporta/sporta_sportamigo_flutter_serverpod/sporta_sportamigo_server/lib/src/di/injectable.dart
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
}
