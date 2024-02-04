import 'package:impaktfull_cli/impaktfull_cli.dart';

class GitUtil {
  static Future<bool> isGitClean(ProcessRunner processRunner) async {
    final impactedLines = await getGitStatus(processRunner);
    return impactedLines.isEmpty;
  }

  static Future<List<String>> getGitStatus(ProcessRunner processRunner) async {
    final result = await processRunner.runProcess([
      'git',
      'status',
      '--porcelain',
    ]);
    if (result.isEmpty) return [];
    return result.trim().split('\n');
  }
}
