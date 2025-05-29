import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/integrations/ci_cd/command/setup/util/ci_cd_setup_os_util.dart';
import 'package:path/path.dart';

class CiCdSetupMacUtil extends CiCdSetupOsUtil {
  CiCdSetupMacUtil({required super.processRunner});

  @override
  Future<void> installOsDependencies() async {
    await _validateZshrc();
    await installHomebrew();
  }

  Future<void> installHomebrew() async {
    ImpaktfullCliLogger.startSpinner("Installing homebrew");
    if (ImpaktfullCliEnvironment.isInstalled(CliTool.brew)) {
      ImpaktfullCliLogger.endSpinnerWithMessage("Homebrew is already installed");
      return;
    }
    await processRunner.requestSudo();
    await processRunner.runProcess(
      [
        '/bin/bash',
        '-c',
        '/bin/bash -c "\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"',
      ],
      runInShell: true,
    );
    ImpaktfullCliLogger.startSpinner("Adding homebrew to .zshrc");
    await _addToZshrc(r'export PATH="/opt/homebrew/bin:$PATH"');
    await _reloadZshrc();
  }

  @override
  Future<void> installChrome() async {
    final path = '/Applications/Google Chrome.app';
    if (Directory(path).existsSync()) {
      ImpaktfullCliLogger.endSpinnerWithMessage("Chrome is already installed");
      return;
    }
    await processRunner.runProcess([
      'brew',
      'install',
      'google-chrome',
    ]);
  }

  @override
  Future<void> installGithubActionsRunner() async {
    ImpaktfullCliLogger.log("\n\n");
    ImpaktfullCliLogger.log("Start github actions runner config");
    ImpaktfullCliLogger.log("https://github.com/organizations/impaktfull/settings/actions/runners/new?arch=arm64&os=osx");
    ImpaktfullCliLogger.log("\nConfigure runner as service");
    ImpaktfullCliLogger.log(
        "https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/configuring-the-self-hosted-runner-application-as-a-service?platform=mac");
    ImpaktfullCliLogger.log("\n");
  }

  @override
  Future<void> installFvm() async {
    if (ImpaktfullCliEnvironment.isInstalled(CliTool.fvm)) {
      ImpaktfullCliLogger.endSpinnerWithMessage("FVM is already installed");
      return;
    }
    await processRunner.runProcess([
      'brew',
      'tap',
      'leoafarias/fvm',
    ]);
    await processRunner.runProcess([
      'brew',
      'install',
      'fvm',
    ]);
  }

  File getZshrcFile() {
    final home = ImpaktfullCliEnvironmentVariables.getEnvVariable("HOME");
    return File(join(home, '.zshrc'));
  }

  Future<void> _validateZshrc() async {
    final zshrcFile = getZshrcFile();
    if (!zshrcFile.existsSync()) {
      throw ImpaktfullCliError("Zshrc not found, install zsh first and try again");
    }
  }

  Future<void> _addToZshrc(String content) async {
    final zshrcFile = getZshrcFile();
    if (!zshrcFile.existsSync()) {
      throw ImpaktfullCliError("${zshrcFile.path} not found");
    }
    final zshrcContent = zshrcFile.readAsStringSync();
    if (zshrcContent.contains(content)) {
      ImpaktfullCliLogger.endSpinnerWithMessage(".zshrc already contains `$content`");
      return;
    }
    zshrcFile.writeAsStringSync(
      content,
      mode: FileMode.append,
    );
  }

  Future<void> _reloadZshrc() async {
    await processRunner.runProcess([
      'bash',
      '-c',
      'source ~/.zshrc',
    ]);
  }
}
