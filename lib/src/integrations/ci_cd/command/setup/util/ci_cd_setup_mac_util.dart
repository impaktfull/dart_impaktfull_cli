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
      ImpaktfullCliLogger.endSpinnerWithMessage(
          "Homebrew is already installed");
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
    await _addToZshrc(
      r'Add homebrew to PATH',
      r'export PATH="/opt/homebrew/bin:$PATH"',
    );
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
    ImpaktfullCliLogger.log(
        "https://github.com/organizations/impaktfull/settings/actions/runners/new?arch=arm64&os=osx");
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
    final content = r"""
export PATH=$PATH:$HOME/.pub-cache/bin
export PATH=$PATH:$HOME/.pub-cache
export PATH=$PATH:$HOME/fvm/default/bin
export PATH=$PATH:$HOME/fvm/default/bin/dart/bin
export PATH=$PATH:$HOME/fvm/default/bin/dart/bin/dart2js
export PATH=$PATH:$HOME/fvm/default/bin/dart/bin/pub
""";
    await _addToZshrc(
      "Add Flutter/Dart paths to PATH variable",
      content,
    );
  }

  File getZshrcFile() {
    final home = ImpaktfullCliEnvironmentVariables.getEnvVariable("HOME");
    return File(join(home, '.zshrc'));
  }

  Future<void> _validateZshrc() async {
    final zshrcFile = getZshrcFile();
    if (!zshrcFile.existsSync()) {
      throw ImpaktfullCliError(
          "Zshrc not found, install zsh first and try again");
    }
  }

  Future<void> _addToZshrc(String comments, String content) async {
    final zshrcFile = getZshrcFile();
    if (!zshrcFile.existsSync()) {
      throw ImpaktfullCliError("${zshrcFile.path} not found");
    }
    final trimmedContent = content.trim();
    final newContent = "#$comments\n$trimmedContent\n";
    final zshrcContent = zshrcFile.readAsStringSync();
    if (zshrcContent.contains(trimmedContent)) {
      ImpaktfullCliLogger.endSpinnerWithMessage(
          ".zshrc already contains `$trimmedContent`");
      return;
    }
    zshrcFile.writeAsStringSync(
      newContent,
      mode: FileMode.append,
    );
    await _reloadZshrc();
  }

  Future<void> _reloadZshrc() async {
    await processRunner.runProcess([
      'source',
      '~/.zshrc',
    ]);
  }
}
