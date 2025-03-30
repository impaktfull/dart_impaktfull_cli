import 'dart:io';

import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';

/// LcovFile represents a parsed LCOV file format.
///
/// LCOV is a file format for code coverage information, commonly used in testing.
/// In LCOV files:
/// - SF: Source file path
/// - DA: Line coverage data (line number, execution count)
/// - LF: Lines Found - total number of instrumented lines
/// - LH: Lines Hit - number of lines with non-zero execution count
/// - end_of_record: Marks the end of a source file record
class LcovFile {
  final List<LcovFileSourceFile> sources;

  double get percentage {
    if (amountOfLines == 0) return 1;
    return amountOfLinesCovered / amountOfLines;
  }

  int get amountOfLines => sources
      .map((e) => e.lines.length)
      .fold<int>(0, (sum, lines) => sum + lines);

  int get amountOfLinesCovered => sources
      .map((e) => e.lines.where((e) => e.hits > 0).length)
      .fold<int>(0, (sum, lines) => sum + lines);

  const LcovFile({
    required this.sources,
  });

  static LcovFile fromFile(File file) {
    final content = file.readAsStringSync();
    return fromString(content);
  }

  static LcovFile fromString(String content) {
    final lines = content.split('\n');
    final sources = <LcovFileSourceFile>[];
    String? currentSourceFilePath;
    List<LcovFileSourceFileLine> currentSourceFileLines = [];
    var linesFound = 0;
    var linesHit = 0;

    for (final line in lines) {
      if (line == 'end_of_record') {
        final sourceFile = LcovFileSourceFile(
          path: currentSourceFilePath!,
          lines: currentSourceFileLines,
        );
        sourceFile._validateLines(linesFound, linesHit);
        sources.add(sourceFile);
        linesFound = 0;
        linesHit = 0;
        currentSourceFilePath = null;
        currentSourceFileLines = [];
      } else if (line.startsWith('SF:')) {
        final path = line.replaceFirst('SF:', '');
        currentSourceFilePath = path;
      } else if (line.startsWith('DA:')) {
        final content = line.replaceFirst('DA:', '');
        final parts = content.split(',');
        final number = int.parse(parts[0]);
        final hits = int.parse(parts[1]);
        final fileLine = LcovFileSourceFileLine(
          number: number,
          hits: hits,
          line: null,
        );
        currentSourceFileLines.add(fileLine);
      } else if (line.startsWith('LF:')) {
        final content = line.replaceFirst('LF:', '');
        linesFound = int.parse(content);
      } else if (line.startsWith('LH:')) {
        final content = line.replaceFirst('LH:', '');
        linesHit = int.parse(content);
      }
    }
    return LcovFile(
      sources: sources,
    );
  }

  LcovFile ignorePatterns(List<RegExp> patterns) {
    final sources = this.sources.where((e) => e.isIgnored(patterns)).toList();
    return LcovFile(
      sources: sources,
    );
  }
}

class LcovFileSourceFile {
  final String path;
  final List<LcovFileSourceFileLine> lines;

  const LcovFileSourceFile({
    required this.path,
    required this.lines,
  });

  void addLine(LcovFileSourceFileLine line) {
    lines.add(line);
  }

  void _validateLines(int linesFound, int linesHit) {
    final amountOfLines = lines.length;
    final amountOfLinesCovered = lines.where((e) => e.hits > 0).length;
    if (amountOfLines != linesFound) {
      throw ImpaktfullCliError(
          'Amount of lines found does not match amount of lines in `$path`');
    }
    if (amountOfLinesCovered != linesHit) {
      throw ImpaktfullCliError(
          'Amount of lines hit does not match amount of lines in `$path`');
    }
  }

  bool isIgnored(List<RegExp> patterns) => patterns.any((pattern) {
        final shouldIgnorePath = pattern.hasMatch(path);
        if (shouldIgnorePath) return true;
        return false;
      });
}

class LcovFileSourceFileLine {
  final int number;
  final int hits;
  final String? line;

  const LcovFileSourceFileLine({
    required this.number,
    required this.hits,
    required this.line,
  });
}
