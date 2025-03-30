import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';
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

  int get amountOfLines => sources.map((e) => e.lines.length).fold<int>(0, (sum, lines) => sum + lines);

  int get amountOfLinesCovered => sources.map((e) => e.lines.where((e) => e.hits > 0).length).fold<int>(0, (sum, lines) => sum + lines);

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
    File? currentSourceFile;
    List<String> currentSourceFileContentLines = [];
    List<LcovFileSourceFileLine> currentSourceFileLines = [];
    var linesFound = 0;
    var linesHit = 0;

    for (final line in lines) {
      if (line == 'end_of_record') {
        final sourceFile = LcovFileSourceFile(
          path: currentSourceFile!.path,
          lines: currentSourceFileLines,
        );
        sourceFile._validateLines(linesFound, linesHit);
        sources.add(sourceFile);
        linesFound = 0;
        linesHit = 0;
        currentSourceFile = null;
        currentSourceFileLines = [];
      } else if (line.startsWith('SF:')) {
        final path = line.replaceFirst('SF:', '');
        currentSourceFile = File(path);
        currentSourceFileContentLines = currentSourceFile.readAsLinesSync();
      } else if (line.startsWith('DA:')) {
        final content = line.replaceFirst('DA:', '');
        final parts = content.split(',');
        final number = int.parse(parts[0]);
        final hits = int.parse(parts[1]);
        final fileLine = LcovFileSourceFileLine(
          lineNumber: number,
          hits: hits,
          lineContent: _getLine(currentSourceFileContentLines, number),
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
    final sources = this.sources.where((e) => !e.isIgnored(patterns)).toList();
    return LcovFile(
      sources: sources,
    );
  }

  @override
  String toString() {
    final sb = StringBuffer();
    for (final source in sources) {
      sb.writeln('SF:${source.path}');
      for (final line in source.lines) {
        sb.writeln('DA:${line.lineNumber},${line.hits}');
      }
      sb.writeln('LF:${source.lines.length}');
      sb.writeln('LH:${source.lines.where((e) => e.hits > 0).length}');
      sb.writeln('end_of_record');
    }
    return sb.toString();
  }

  LcovFile removePrivateConstConstructors() {
    // Updated regex to match private const constructors like "const SessionLogger._();"
    // The previous regex was too strict with whitespace and didn't account for possible variations
    final regex = RegExp(r'const\s+\w+\._\(\);');
    final sources = this.sources.map((e) {
      final newLines = <LcovFileSourceFileLine>[];
      for (final line in e.lines) {
        final lineContent = line.lineContent?.trim();
        if (lineContent == null || !regex.hasMatch(lineContent)) {
          newLines.add(line);
        }
      }
      return LcovFileSourceFile(
        path: e.path,
        lines: newLines,
      );
    }).toList();
    return LcovFile(
      sources: sources,
    );
  }

  static String? _getLine(List<String> currentSourceFileContentLines, int number) {
    if (currentSourceFileContentLines.isEmpty) return null;
    return currentSourceFileContentLines[number - 1];
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
      throw ImpaktfullCliError('Amount of lines found does not match amount of lines in `$path`');
    }
    if (amountOfLinesCovered != linesHit) {
      throw ImpaktfullCliError('Amount of lines hit does not match amount of lines in `$path`');
    }
  }

  bool isIgnored(List<RegExp> patterns) => patterns.any((pattern) {
        final matchesPattern = pattern.hasMatch(path);
        if (matchesPattern) return true;
        return false;
      });
}

class LcovFileSourceFileLine {
  final int lineNumber;
  final int hits;
  final String? lineContent;

  const LcovFileSourceFileLine({
    required this.lineNumber,
    required this.hits,
    required this.lineContent,
  });
}
