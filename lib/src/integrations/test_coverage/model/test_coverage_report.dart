import 'package:impaktfull_cli/src/integrations/test_coverage/model/lcov/lcov_file.dart';

class TestCoverageReport {
  final String name;
  final double? _percentage;
  final int? _amountOfLines;
  final int? _amountOfLinesCovered;
  final LcovFile? _lcovFile;

  double get percentage => _percentage ?? _lcovFile?.percentage ?? 0;

  int get amountOfLines => _amountOfLines ?? _lcovFile?.amountOfLines ?? 0;

  int get amountOfLinesCovered =>
      _amountOfLinesCovered ?? _lcovFile?.amountOfLinesCovered ?? 0;

  LcovFile get lcovFile => _lcovFile!;

  TestCoverageReport({
    required this.name,
    required double percentage,
    required int amountOfLines,
    required int amountOfLinesCovered,
  })  : _percentage = percentage,
        _amountOfLines = amountOfLines,
        _amountOfLinesCovered = amountOfLinesCovered,
        _lcovFile = null;

  TestCoverageReport.lcov({
    required this.name,
    required LcovFile lcovFile,
  })  : _lcovFile = lcovFile,
        _percentage = lcovFile.percentage,
        _amountOfLines = lcovFile.amountOfLines,
        _amountOfLinesCovered = lcovFile.amountOfLinesCovered;

  String printReport(String name) {
    final percentage = (lcovFile.percentage * 100).toStringAsFixed(2);
    final amountOfLinesCovered = lcovFile.amountOfLinesCovered;
    final amountOfLines = lcovFile.amountOfLines;
    final sb = StringBuffer();
    sb.writeln('\n$name test coverage:');
    if (amountOfLines == 0) {
      sb.writeln(
          '=> The test coverage report does not contain any lines! Did you write any tests?');
    } else {
      sb.writeln('=> $percentage% ($amountOfLinesCovered / $amountOfLines)');
    }
    return sb.toString();
  }
}
