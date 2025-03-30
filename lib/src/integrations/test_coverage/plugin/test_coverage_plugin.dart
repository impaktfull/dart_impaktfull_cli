import 'dart:io';

import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/core/plugin/impaktfull_cli_plugin.dart';
import 'package:impaktfull_cli/src/core/util/process/process_runner.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/model/lcov/lcov_file.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/model/test_coverage_report.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/model/test_coverage_type.dart';
import 'package:path/path.dart';

class TestCoveragePlugin extends ImpaktfullCliPlugin {
  const TestCoveragePlugin({
    super.processRunner = const CliProcessRunner(),
  });

  Future<TestCoverageReport> testCoverage({
    required String path,
    required TestCoverageType type,
    String outputPath = 'coverage',
    List<String> ignorePatterns = const [],
    bool useFvm = false,
    bool verbose = false,
  }) async {
    if (outputPath.isEmpty) {
      throw ImpaktfullCliError('Output path cannot be empty');
    }
    final fileName = type.name;
    final file = File(join(outputPath, fileName));
    if (!file.existsSync()) {
      throw ImpaktfullCliError('$fileName not found');
    }
    final lcovFile = await _cleanupLcovFile(
      file: file,
      ignorePatterns: ignorePatterns,
    );
    return TestCoverageReport.lcov(
      name: path,
      lcovFile: lcovFile,
    );
  }

  Future<LcovFile> _cleanupLcovFile({
    required File file,
    required List<String> ignorePatterns,
  }) async {
    final lcovFile = LcovFile.fromFile(file);
    return lcovFile;
  }
}
