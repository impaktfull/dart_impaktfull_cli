import 'package:impaktfull_cli/src/core/model/data/environment/cli_tool.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/core/plugin/impaktfull_cli_plugin.dart';
import 'package:impaktfull_cli/src/core/util/args/env/impaktfull_cli_environment.dart';
import 'package:impaktfull_cli/src/core/util/git/git_util.dart';
import 'package:impaktfull_cli/src/core/util/process/process_runner.dart';

class GitPlugin extends ImpaktfullCliPlugin {
  const GitPlugin({
    super.processRunner = const CliProcessRunner(),
  });

  /// If git is not installed, it is considered clean
  Future<bool> isGitClean() async {
    final isGitInstalled = ImpaktfullCliEnvironment.isInstalled(CliTool.git);
    if (!isGitInstalled) return true;
    return GitUtil.isGitClean(processRunner);
  }

  Future<void> validateGitClean() async {
    final isGitClean = await this.isGitClean();
    if (!isGitClean) {
      throw ImpaktfullCliError(
          'Git is not clean. Please commit or stash your changes before bumping the version.');
    }
  }

  // TODO: Implement this
  Future<bool> isGitProject() async => true;
}
